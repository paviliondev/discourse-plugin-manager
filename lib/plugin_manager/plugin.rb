# frozen_string_literal: true

class ::PluginManager::Plugin
  PAGE_LIMIT = 30
  TAG_GROUP ||= 'plugin_manager_plugin_tags'

  include ActiveModel::Serialization

  attr_accessor :branch,
                :discourse_branch,
                :status,
                :support_category_id,
                :documentation_category_id,
                :group_id

  attr_reader   :name,
                :url,
                :branches,
                :default_branch,
                :authors,
                :about,
                :contact_emails,
                :maintainers,
                :repository_host,
                :test_host,
                :owner,
                :local,
                :tags

  def initialize(name, attrs)
    @name = name

    @url = attrs[:url]
    @authors = attrs[:authors]
    @about = attrs[:about]
    @contact_emails = attrs[:contact_emails]
    @maintainers = attrs[:maintainers]
    @support_category_id = attrs[:support_category_id]
    @documentation_category_id = attrs[:documentation_category_id]
    @group_id = attrs[:group_id]
    @tags = attrs[:tags]
    @branches = attrs[:branches]
    @default_branch = attrs[:default_branch]
    @local = attrs[:local]

    if attrs[:owner].present?
      @owner = PluginManager::RepositoryOwner.new(attrs[:owner])
    end

    if attrs[:repository_host].present?
      @repository_host = PluginManager::RepositoryHost.get(attrs[:repository_host])
    end

    if attrs[:test_host].present?
      @test_host = attrs[:test_host]
    end
  end

  def display_name
    name.titleize
  end

  def branch_url
    @branch_url ||= begin
      return nil unless branch && @repository_host.present?
      @repository_host.url = url
      @repository_host.branch = branch
      @repository_host.branch_url
    end
  end

  def users
    group ? group.users : []
  end

  def add_user(user)
    group && group.add(user)
  end

  def group
    @group ||= begin
      if group_id
        Group.find_by(id: group_id)
      elsif
        Group.find_by(name: name)
      else
        nil
      end
    end
  end

  def documentation_category
    @documentation_category ||= begin
      Category.find_by(id: documentation_category_id)
    end
  end

  def support_category
    @support_category ||= begin
      Category.find_by(id: support_category_id)
    end
  end

  def documentation_category_tags
    @documentation_category_tags ||= begin
      if documentation_category&.topic
        documentation_category.topic.tags.map(&:name)
      else
        []
      end
    end
  end

  def maintainer
    maintainers.present? ? maintainers.first : nil
  end

  def self.set(plugin_name, attrs)
    plugin = get(plugin_name)

    new_attrs = {
      url: attrs[:url] ? attrs[:url].chomp(".git") : plugin.url,
      authors: attrs[:authors] || plugin.authors,
      about: attrs[:about] || plugin.about,
      contact_emails: attrs[:contact_emails] || plugin.contact_emails,
      maintainers: attrs[:maintainers] || plugin.maintainers,
      owner: attrs[:owner]&.instance_values || plugin.owner&.instance_values,
      documentation_category_id: attrs[:documentation_category_id] || plugin.documentation_category_id,
      support_category_id: attrs[:support_category_id] || plugin.support_category_id,
      default_branch: attrs[:default_branch] || plugin.default_branch,
      branches: plugin.branches || [],
      test_host: attrs[:test_host] || plugin.test_host,
      tags: attrs[:tags] || plugin.tags
    }

    [:branch, :default_branch].each do |key|
      if attrs[key] && new_attrs[:branches].exclude?(attrs[key])
        new_attrs[:branches] << attrs[key]
      end
    end

    new_attrs = update_repository_attrs(new_attrs[:url], new_attrs)
    PluginManagerStore.set(::PluginManager::NAMESPACE, plugin_name, new_attrs)

    status_attrs = attrs.slice(:status, :test_status, :backtrace, :message)
    git = attrs.slice(*PluginManager::Plugin::Status.required_git_attrs)

    if status_attrs.present? && git.present?
      PluginManager::Plugin::Status.update(plugin_name, git, status_attrs)
    end

    update_associations(plugin_name)
  end

  def self.update_repository_attrs(url, attrs)
    manager = ::PluginManager::RepositoryManager.new(url)

    unless attrs[:default_branch]
      attrs[:default_branch] = manager.get_default_branch
    end

    manager.host.branch = attrs[:default_branch]

    if manager.ready?
      attrs[:repository_host] = manager.host.name

      if owner = manager.get_owner
        attrs[:owner] = owner.instance_values
      end
    end

    attrs
  end

  def self.update_associations(plugin_name)
    plugin = get(plugin_name)

    unless Rails.env.test?
      ActiveRecord::Base.transaction do
        update_categories(plugin)
        update_group(plugin)
      end
    end

    plugin
  end

  def self.get(plugin_name)
    raw = ::PluginManagerStore.get(::PluginManager::NAMESPACE, plugin_name) || {}
    new(plugin_name, raw)
  end

  def self.remove(plugin_name)
    ::PluginStore.remove(::PluginManager::NAMESPACE, plugin_name)
  end

  def self.exists?(plugin_name)
    ::PluginStoreRow.exists?(plugin_name: ::PluginManager::NAMESPACE, key: plugin_name)
  end

  def self.list(page: 0, filter: nil, order: nil, asc: true, tags: nil, all_tags: false)
    query = ::PluginStoreRow.where(plugin_name: ::PluginManager::NAMESPACE)
    list_query(query, page: page, filter: filter, order: order, asc: asc, tags: tags, all_tags: all_tags)
  end

  def self.list_by(attr, value)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' = ?", value.to_s)
    list_query(query)
  end

  def self.find_by_category_id(value)
    query = ::PluginStoreRow.where("
      plugin_name = '#{::PluginManager::NAMESPACE}'
      AND (
        value::json->>'documentation_category_id' = :category_id OR
        value::json->>'support_category_id' = :category_id
      )", category_id: value.to_s)
    query.exists? ? create_from_record(query.first) : nil
  end

  def self.with_attr(attr)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' IS NOT NULL")
    list_query(query)
  end

  def self.list_query(query, page: nil, filter: nil, order: nil, asc: nil, tags: nil, all_tags: false)
    if filter.present?
      query = query.where("
        key ~ '#{filter}' OR
        value::json->>'about' ~ '#{filter}' OR
        (value::json->>'owner')::json->>'name' ~ '#{filter}' OR
        (value::json->>'owner')::json->>'description' ~ '#{filter}'
      ")
    end

    if tags.present?
      query = query.where("(value::json->>'tags')::jsonb #{all_tags ? "?&" : "?|"} '{#{tags.join(",")}}'")
    end

    if order.present?
      direction = asc.present? && ActiveRecord::Type::Boolean.new.cast(asc) ? "ASC" : "DESC"
      order_query = {
        plugin_name: "key",
        owner_name: "(value::json->>'owner')::json->>'name'"
      }[order.to_sym]
      query = query.order("(#{order_query}) #{direction}")
    end

    if page
      query = query.limit(PAGE_LIMIT).offset(page * PAGE_LIMIT)
    end

    query.map { |record| create_from_record(record) }
  end

  def self.create_from_record(record)
    name = record.key

    begin
      attrs = JSON.parse(record.value)
    rescue JSON::ParserError
      attrs = {}
    end

    new(name, attrs.with_indifferent_access)
  end

  def self.retrieve_from_url(url)
    result = OpenStruct.new(plugin: {}, error: '', success: false)

    manager = PluginManager::RepositoryManager.new(url)
    manager.use_default_branch

    if !manager.ready?
      result.error = I18n.t("plugin_manager.plugin.error.failed_to_retrieve_plugin")
      return result
    end

    plugin_data = manager.get_plugin_data
    if !plugin_data || !plugin_data.file
      result.error = I18n.t("plugin_manager.plugin.error.failed_to_retrieve_plugin")
      return result
    end

    metadata = ::Plugin::Metadata.parse(plugin_data.file)
    if exists?(metadata.name)
      result.error = I18n.t("plugin_manager.plugin.error.plugin_already_exists")
      return result
    end

    result.plugin = {
      name: metadata.name.dasherize,
      contact_emails: metadata.contact_emails,
      authors: metadata.authors,
      about: metadata.about,
      url: url
    }
    result.success = true
    result
  end

  def self.update_categories(plugin)
    %w[documentation support].each do |category_type|
      next unless (parent_category_id = SiteSetting.send("plugin_manager_#{category_type}_category")).present?

      category = Category.find_by(parent_category_id: parent_category_id, slug: plugin.name)
      category = create_category(category_type, plugin) unless category
      category = update_category(category, category_type, plugin)

      if category && plugin.send("#{category_type}_category_id") != category.id
        opts = {}
        opts["#{category_type}_category_id".to_sym] = category.id
        set(plugin.name, opts)
      end
    end
  end

  def self.update_category(category, category_type, plugin)
    category.description = plugin.about
    category.custom_fields['plugin_name'] = plugin.name
    category.custom_fields['plugin_maintainer'] = plugin.maintainer if category_type === "support"
    category.custom_fields["plugin_#{category_type}"] = true

    begin
      category.save!
    rescue => e
      raise Discourse::InvalidParameters, "Failed to save category"
    end

    category
  end

  def self.create_category(category_type, plugin)
    begin
      display_name = plugin.display_name
      Category.new(
        name: display_name,
        slug: plugin.name,
        description: I18n.t("plugin_manager.plugin.#{category_type}_category_description", plugin_name: display_name),
        user: Discourse.system_user,
        parent_category_id: SiteSetting.send("plugin_manager_#{category_type}_category"),
        permissions: {
          everyone: CategoryGroup.permission_types[:create_post],
          staff: CategoryGroup.permission_types[:full]
        }
      )
    rescue ArgumentError => e
      raise Discourse::InvalidParameters, "Failed to create category"
    end
  end

  def self.update_group(plugin)
    group = plugin.group

    if !group
      group =
        begin
          Group.new(
            name: plugin.name,
            full_name: plugin.display_name,
            bio_raw: I18n.t("plugin_manager.group.name", plugin_name: plugin.display_name)
          )
        rescue ArgumentError => e
          raise Discourse::InvalidParameters, "Failed to create group"
        end
      group.save
    end

    if group && plugin.group_id != group.id
      set(plugin.name, group_id: group.id)
    end
  end

  def self.update_plugins
    list.each do |plugin|
      result = retrieve_from_url(plugin.url)

      if result.success
        set(plugin.name, result.plugin)
      end
    end
  end

  def self.update_test_statuses
    with_attr('test_host').each do |plugin|
      test_manager = PluginManager::TestManager.new(plugin.test_host, plugin.default_branch, 'tests-passed')

      if test_manager.ready?
        test_manager.update(plugin.name)
      end
    end
  end

  def self.update_local_plugins
    compatible_plugin_paths = build_local_paths("#{PluginManager.root_dir}/#{PluginManager.compatible_dir}")
    incompatible_plugins_paths = build_local_paths("#{PluginManager.root_dir}/#{PluginManager.incompatible_dir}")
    plugin_paths = compatible_plugin_paths + incompatible_plugins_paths

    plugin_paths.each do |path|
      set_local(path)
    end
  end

  def self.set_local(path)
    begin
      file = File.read("#{path}/plugin.rb")
    rescue
      return nil
    end
    metadata = ::Plugin::Metadata.parse(file)

    if metadata.present?
      incompatible = path.include?(PluginManager.incompatible_dir)
      status =
        if incompatible
          PluginManager::Plugin::Status.statuses[:incompatible]
        else
          PluginManager::Plugin::Status.statuses[:compatible]
        end

      attrs = {
        url: get_local_url(path),
        contact_emails: metadata.contact_emails,
        authors: metadata.authors,
        about: metadata.about,
        version: metadata.version,
        branch: get_local_branch(path),
        sha: get_local_sha(path),
        discourse_branch: Discourse.git_branch,
        discourse_sha: Discourse.git_version,
        status: status,
        test_host: PluginManager::TestHost.detect_local(path)
      }

      set(metadata.name, attrs)
    end
  end

  def self.build_local_paths(root_path)
    Dir.children(root_path).reduce([]) do |result, file|
      if excluded_local_plugins.exclude?(file)
        result << "#{root_path}/#{file}"
      end
      result
    end
  end

  def self.get_local_sha(path)
    PluginManager.run_shell_cmd('git rev-parse HEAD', { chdir: path })
  end

  def self.get_local_branch(path)
    PluginManager.run_shell_cmd('git rev-parse --abbrev-ref HEAD', { chdir: path })
  end

  def self.get_local_url(path)
    PluginManager.run_shell_cmd('git config --get remote.origin.url', { chdir: path })
  end

  def self.excluded_local_plugins
    %w(
      docker_manager
      discourse-plugin-manager
      discourse-plugin-guard
      discourse-code-review
      discourse-details
      discourse-local-dates
      discourse-narrative-bot
      discourse-presence
      lazy-yt
      poll
      styleguide
      chat
    )
  end
end

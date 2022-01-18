# frozen_string_literal: true
class ::PluginManager::Plugin
  PAGE_LIMIT = 30

  include ActiveModel::Serialization

  attr_accessor :name,
                :url,
                :authors,
                :about,
                :version,
                :contact_emails,
                :sha,
                :git_branch,
                :status,
                :repository_host,
                :test_host,
                :test_status,
                :test_backend_coverage,
                :instance,
                :status_changed_at,
                :support_url,
                :try_url,
                :from_file,
                :category_id,
                :group_id

  attr_reader   :owner,
                :host

  def initialize(plugin_name, attrs)
    @name = plugin_name
    @url = attrs[:url]
    @authors = attrs[:authors]
    @about = attrs[:about]
    @version = attrs[:version]
    @contact_emails = attrs[:contact_emails]
    @sha = attrs[:sha]
    @git_branch = attrs[:git_branch]
    @status = attrs[:status].to_i
    @status_changed_at = attrs[:status_changed_at]
    @repository_host = attrs[:repository_host] if attrs[:repository_host].present?
    @test_host = attrs[:test_host] if attrs[:test_host].present?
    @test_status = attrs[:test_status].to_i if attrs[:test_status].present?
    @test_backend_coverage = attrs[:test_backend_coverage].to_f if attrs[:test_backend_coverage].present?
    @owner = PluginManager::RepositoryOwner.new(attrs[:owner]) if attrs[:owner].present?
    @host = PluginManager::RepositoryHost.get(attrs[:repository_host]) if attrs[:repository_host].present?
    @support_url = attrs[:support_url]
    @try_url = attrs[:try_url]
    @from_file = attrs[:from_file]
    @category_id = attrs[:category_id]
    @group_id = attrs[:group_id]

    if @from_file
      @instance = Discourse.plugins.select { |p| p.metadata.name == plugin_name }.first
    end
  end

  def present?
    sha.present?
  end

  def display_name
    name.titleize
  end

  def local?
    from_file
  end

  def remote?
    !from_file
  end

  def branch_url
    @branch_url ||= begin
      return nil unless @host.present?
      @host.url = url
      @host.branch = git_branch
      @host.branch_url
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
        Group.find_by_id(id: group_id)
      elsif
        Group.find_by(name: name)
      else
        nil
      end
    end
  end

  def category
    @category ||= begin
      if category_id
        Category.find_by_id(id: category_id)
      elsif
        Category.find_by(slug: name)
      else
        nil
      end
    end
  end

  def self.set(plugin_name, attrs)
    plugin = get(plugin_name)

    from_file = attrs[:from_file] || plugin.from_file || false
    url = (attrs[:url] || plugin.url).chomp(".git")

    new_attrs = {
      url: url,
      sha: attrs[:sha] || plugin.sha,
      git_branch: attrs[:git_branch] || plugin.git_branch,
      authors: attrs[:authors] || plugin.authors,
      about: attrs[:about] || plugin.about,
      version: attrs[:version] || plugin.version,
      contact_emails: attrs[:contact_emails] || plugin.contact_emails,
      test_host: attrs[:test_host] || plugin.test_host,
      test_backend_coverage: attrs[:test_backend_coverage] || plugin.test_backend_coverage,
      test_status: attrs[:test_status].nil? ? plugin.test_status : attrs[:test_status].to_i,
      status: attrs[:status].nil? ? plugin.status : attrs[:status].to_i,
      owner: attrs[:owner]&.instance_values || plugin.owner&.instance_values,
      support_url: attrs[:support_url] || plugin.support_url,
      try_url: attrs[:try_url] || plugin.try_url,
      from_file: from_file,
      category_id: attrs[:category_id] || plugin.category_id
    }

    repo_manager = ::PluginManager::RepositoryManager.new(url, new_attrs[:git_branch])
    if repo_manager.ready?
      new_attrs[:repository_host] = repo_manager.host.name

      if owner = repo_manager.get_owner
        new_attrs[:owner] = owner.instance_values
      end
    end

    manifest = PluginManager::Manifest
    test_manager = PluginManager::TestManager

    if manifest.incompatible?(new_attrs[:status])
      new_attrs[:status] = manifest.status[:incompatible]
    elsif test_manager.failing?(new_attrs[:test_status])
      new_attrs[:status] = manifest.status[:tests_failing]
    elsif test_manager.passing?(new_attrs[:test_status]) && test_manager.recommended_coverage?(new_attrs[:test_backend_coverage])
      new_attrs[:status] = manifest.status[:recommended]
    elsif manifest.compatible?(new_attrs[:status])
      new_attrs[:status] = manifest.status[:compatible]
    else
      new_attrs[:status] = manifest.status[:unknown]
    end

    old_status = plugin.status
    new_status = new_attrs[:status]
    status_changed = old_status != new_status
    new_attrs[:status_changed_at] = status_changed ? Time.now : plugin.status_changed_at

    saved = ::PluginManagerStore.set(::PluginManager::NAMESPACE, plugin_name, new_attrs)

    if saved
      status_handler = ::PluginManager::StatusHandler.new(plugin_name)
      status_handler.perform(old_status, new_status)
    end

    saved
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

  def self.get_or_create(plugin_name)
    plugin = get(plugin_name)
    plugin = set_from_file("#{PluginManager.root_dir}/#{PluginManager.compatible_dir}/#{plugin_name}") if !plugin.present?
    plugin
  end

  def self.list(with_plugin_manager: false, page: 0, filter: nil, order: nil, asc: true)
    query = ::PluginStoreRow.where(plugin_name: ::PluginManager::NAMESPACE)
    list_query(query, with_plugin_manager, page: page, filter: filter, order: order, asc: asc)
  end

  def self.list_by(attr, value, with_plugin_manager: false)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' = ?", value.to_s)
    list_query(query, with_plugin_manager)
  end

  def self.with_attr(attr, with_plugin_manager: false)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' IS NOT NULL")
    list_query(query, with_plugin_manager)
  end

  def self.list_query(query, with_plugin_manager, page: nil, filter: nil, order: nil, asc: nil)
    query = query.where.not(key: "discourse-plugin-manager") unless with_plugin_manager

    if filter.present?
      query = query.where("
        key ~ '#{filter}' OR
        value::json->>'about' ~ '#{filter}' OR
        (value::json->>'owner')::json->>'name' ~ '#{filter}' OR
        (value::json->>'owner')::json->>'description' ~ '#{filter}'
      ")
    end

    if order.present?
      direction = asc.present? && ActiveRecord::Type::Boolean.new.cast(asc) ? "ASC" : "DESC"
      order_query = {
        plugin_name: "key",
        plugin_status: "value::json->>'status'",
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

  def self.retrieve_from_url(url, branch)
    manager = PluginManager::RepositoryManager.new(url, branch)
    result = OpenStruct.new(plugin: {}, error: '', success: false)

    if !manager.ready?
      result.error = I18n.t("plugin_manager.plugin.error.failed_to_retrieve_plugin")
      return result
    end

    plugin_data = manager.get_plugin_data
    if !plugin_data || !plugin_data.file || !plugin_data.sha
      result.error = I18n.t("plugin_manager.plugin.error.failed_to_retrieve_plugin")
      return result
    end

    metadata = ::Plugin::Metadata.parse(plugin_data.file)
    if exists?(metadata.name)
      result.error = I18n.t("plugin_manager.plugin.error.plugin_already_exists")
      return result
    end

    result.plugin = {
      sha: plugin_data.sha,
      name: metadata.name,
      contact_emails: metadata.contact_emails,
      authors: metadata.authors,
      about: metadata.about,
      version: metadata.version
    }
    result.success = true
    result
  end

  def self.set_from_file(path)
    begin
      file = File.read("#{path}/plugin.rb")
    rescue
      return nil
    end
    metadata = ::Plugin::Metadata.parse(file)

    if metadata.present? && ::PluginManager::Manifest.excluded.exclude?(metadata.name)
      sha = get_local_sha(path)
      branch = get_local_branch(path)
      url = get_local_url(path)
      test_host = PluginManager::TestHost.detect_local(path)
      try_url = get_try_url(metadata, branch)
      status = path.include?(PluginManager.incompatible_dir) ?
        PluginManager::Manifest.status[:incompatible] :
        PluginManager::Manifest.status[:compatible]

      attrs = {
        url: url,
        contact_emails: metadata.contact_emails,
        authors: metadata.authors,
        about: metadata.about,
        version: metadata.version,
        sha: sha,
        git_branch: branch,
        status: status,
        from_file: true,
        test_host: test_host,
        try_url: try_url
      }

      set(metadata.name, attrs)
      plugin = get(metadata.name)

      update_category(plugin)
      update_group(plugin)
    end
  end

  def self.update_category(plugin)
    category = plugin.category

    if category
      category.description = build_category_description(plugin)
      category.save
    else
      category =
        begin
          Category.new(
            name: plugin.display_name,
            slug: plugin.name,
            description: build_category_description(plugin),
            user: Discourse.system_user
          )
        rescue ArgumentError => e
          raise Discourse::InvalidParameters, "Failed to create category"
        end
      category.save
    end

    if plugin.category_id != category.id
      set(metadata.name, category_id: category.id)
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

    set(plugin.name, group_id: group.id) if group.present?
  end

  def self.extra_metadata
    [
      :tests_passed_try_url,
      :stable_try_url
    ]
  end

  def self.add_extra_metadata
    extra_metadata.each do |field|
      if ::Plugin::Metadata::FIELDS.exclude?(field)
        ::Plugin::Metadata::FIELDS << field
        ::Plugin::Metadata.attr_accessor field
      end
    end
  end

  def self.build_category_description(plugin)
    description = plugin.about
    description += " #{I18n.t("plugin_manager.plugin.try_url", try_url: plugin.try_url)}" if plugin.try_url
    description
  end

  def self.get_try_url(metadata, branch)
    metadata.respond_to?("#{branch.underscore}_try_url") && metadata.send("#{branch.underscore}_try_url")
  end

  def self.get_local_sha(path)
    PluginManager.run_shell_cmd('git rev-parse HEAD', chdir: path)
  end

  def self.get_local_branch(path)
    PluginManager.run_shell_cmd('git rev-parse --abbrev-ref HEAD', chdir: path)
  end

  def self.get_local_url(path)
    PluginManager.run_shell_cmd('git config --get remote.origin.url', chdir: path)
  end

  def self.get_local_path(plugin_name, status)
    folder = status == self.class.status[:incompatible] ? PluginManager.incompatible_dir : PluginManager.compatible_dir
    parent_path = "#{PluginManager.root_dir}/#{folder}"
    path = nil

    Dir["#{parent_path}/*/plugin.rb"].each do |p|
      metadata = Plugin::Metadata.parse(File.read(p))
      plugin = self.new(metadata, path)
      if plugin.name === plugin_name
        path = p
      end
    end

    path
  end

  def self.get_sha(plugin_name)
    plugin = get(plugin_name)
    sha = plugin ? plugin.sha : nil

    if !plugin || (plugin.local? && !sha)
      path = get_local_path(plugin_name, status)
      sha = get_local_sha(path) if path
    end

    sha
  end

  def self.get_branch(plugin_name)
    plugin = get(plugin_name)
    branch = plugin ? plugin.git_branch : nil

    if !plugin || (plugin.local? && !branch)
      path = get_local_path(plugin_name, status)
      branch = get_local_branch(path) if path
    end

    branch
  end
end

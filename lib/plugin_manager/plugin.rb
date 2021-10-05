class ::PluginManager::Plugin
  include ActiveModel::Serialization

  attr_accessor :name,
                :url,
                :contact_emails,
                :installed_sha,
                :git_branch,
                :status,
                :test_host,
                :test_status,
                :test_backend_coverage,
                :instance,
                :status_changed_at

  def initialize(plugin_name, attrs)
    @name = plugin_name
    @url = attrs[:url]
    @contact_emails = attrs[:contact_emails]
    @installed_sha = attrs[:installed_sha]
    @git_branch = attrs[:git_branch]
    @status = attrs[:status].to_i
    @status_changed_at = attrs[:status_changed_at]
    @test_host = attrs[:test_host] if attrs[:test_host].present?
    @test_status = attrs[:test_status].to_i if attrs[:test_status].present?
    @test_backend_coverage = attrs[:test_backend_coverage].to_f if attrs[:test_backend_coverage].present?
    @instance = Discourse.plugins.select { |p| p.metadata.name == plugin_name }.first
  end

  def present?
    installed_sha.present?
  end

  def display_name
    name.titleize
  end

  def self.set(plugin_name, attrs)
    plugin = get(plugin_name)

    new_attrs = {
      url: attrs[:url] || plugin.url,
      installed_sha: attrs[:installed_sha] || plugin.installed_sha,
      git_branch: attrs[:git_branch] || plugin.git_branch,
      contact_emails: attrs[:contact_emails] || plugin.contact_emails,
      test_host: attrs[:test_host] || plugin.test_host,
      test_backend_coverage: attrs[:test_backend_coverage] || plugin.test_backend_coverage,
      test_status: attrs[:test_status].nil? ? plugin.test_status : attrs[:test_status].to_i,
      status: attrs[:status].nil? ? plugin.status : attrs[:status].to_i
    }

    manifest = PluginManager::Manifest
    test_manager = PluginManager::TestManager

    if manifest.incompatible?(new_attrs[:status])
      new_attrs[:status] = manifest.status[:incompatible]
    elsif test_manager.failing?(new_attrs[:test_status])
      new_attrs[:status] = manifest.status[:tests_failing]
    elsif test_manager.passing?(new_attrs[:test_status]) && test_manager.recommended_coverage?(new_attrs[:test_backend_coverage])
      new_attrs[:status] = manifest.status[:recommended]
    else
      new_attrs[:status] = manifest.status[:compatible]
    end

    old_status = plugin.status
    new_status = new_attrs[:status]
    status_changed = old_status != new_status
    new_attrs[:status_changed_at] = status_changed ? Time.now : plugin.status_changed_at

    saved = ::PluginStore.set(::PluginManager::NAMESPACE, plugin_name, new_attrs)

    if saved && status_changed
      PluginManager::Manifest.handle_status_change(plugin_name, old_status, new_status)
    end

    saved
  end

  def self.get(plugin_name)
    raw = ::PluginStore.get(::PluginManager::NAMESPACE, plugin_name) || {}
    new(plugin_name, raw)
  end

  def self.get_or_create(plugin_name)
    plugin = get(plugin_name)
    plugin = set_from_file("#{Rails.root}/plugins/#{plugin_name}") if !plugin.present?
    plugin
  end

  def self.list(with_plugin_manager: false)
    query = ::PluginStoreRow.where(plugin_name: ::PluginManager::NAMESPACE)
    list_query(query, with_plugin_manager)
  end

  def self.list_by(attr, value, with_plugin_manager: false)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' = ?", value.to_s)
    list_query(query, with_plugin_manager)
  end

  def self.with_attr(attr, with_plugin_manager: false)
    query = ::PluginStoreRow.where("plugin_name = '#{::PluginManager::NAMESPACE}' AND value::json->>'#{attr}' IS NOT NULL")
    list_query(query, with_plugin_manager)
  end

  def self.list_query(query, with_plugin_manager)
    query = query.where.not(key: "discourse-plugin-manager-server") unless with_plugin_manager
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

  def self.set_from_file(path)
    begin
      file = File.read("#{path}/plugin.rb")
    rescue
      return nil
    end

    metadata = ::Plugin::Metadata.parse(file)
    if metadata.present? && ::PluginManager::Manifest.excluded.exclude?(metadata.name)
      sha = nil
      branch = nil
      test_host = nil

      Dir.chdir(path) do
        sha = `git rev-parse HEAD`.strip
        branch = `git rev-parse --abbrev-ref HEAD`.strip
        test_host = PluginManager::TestHost.detect
      end

      attrs = {
        url: metadata.url,
        contact_emails: metadata.contact_emails,
        installed_sha: sha,
        git_branch: branch,
        status: path.include?(PluginManager::Manifest::INCOMPATIBLE_FOLDER) ?
          PluginManager::Manifest.status[:incompatible] :
          PluginManager::Manifest.status[:compatible]
      }
      attrs[:test_host] = test_host if test_host

      ::PluginManager::Plugin.set(metadata.name, attrs)
      ::PluginManager::Plugin.get(metadata.name)
    end
  end
end

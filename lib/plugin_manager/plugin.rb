class ::PluginManager::Plugin
  attr_accessor :name,
                :url,
                :installed_sha,
                :git_branch,
                :status
  
  def initialize(plugin_name, attrs)
    @name = plugin_name
    @url = attrs[:url]
    @installed_sha = attrs[:installed_sha]
    @git_branch = attrs[:git_branch]
    @status = attrs[:status]
  end

  def self.set(plugin_name, params)
    plugin = get(plugin_name)
    
    plugin.url = params[:url]
    plugin.installed_sha = params[:installed_sha]
    plugin.git_branch = params[:git_branch]
    
    if plugin.status != params[:status]
      plugin.status = params[:status]
      handle_change(plugin_name, params)
    end

    PluginStore.set(::PluginManager::PLUGIN_NAME, plugin_name, plugin.as_json)
  end
  
  def self.get(plugin_name)
    raw = PluginStore.get(::PluginManager::PLUGIN_NAME, plugin_name) || {}
    new(plugin_name, raw)
  end
  
  def self.list_by(attr, value)
    PluginStoreRow.where("
      plugin_name = '#{::PluginManager::PLUGIN_NAME}' AND
      value::json->>'#{attr}' = ?
    ", value.to_s).map do |record|
      create_from_record(record)
    end
  end
  
  def self.with_attr(attr)
    PluginStoreRow.where("
      plugin_name = '#{::PluginManager::PLUGIN_NAME}' AND
      value::json->>'#{attr}' IS NOT NULL
    ").map do |record|
      create_from_record(record)
    end
  end
  
  def self.create_from_record(record)
    name = record.key
    
    begin
      attrs = JSON.parse(record.value)
    rescue JSON::ParserError
      attrs = {}
    end
    
    new(name, attrs)
  end
    
  def self.handle_change(plugin_name, params)
    if params[:status] == ::PluginManager::Manifest.status[:incompatible]
      Jobs.enqueue(:send_plugin_incompatible_notification,
        plugin: name,
        site: SiteSetting.title
      )
    end
  end
end
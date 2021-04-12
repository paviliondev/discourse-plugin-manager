class ::PluginManager::Plugin
  attr_accessor :name,
                :url,
                :contact_emails,
                :installed_sha,
                :git_branch,
                :status
  
  def initialize(plugin_name, attrs)
    @name = plugin_name
    @url = attrs[:url]
    @contact_emails = attrs[:contact_emails]
    @installed_sha = attrs[:installed_sha]
    @git_branch = attrs[:git_branch]
    @status = attrs[:status]
  end

  def self.set(plugin_name, params)
    plugin = get(plugin_name)
    
    plugin.url = params[:url]
    plugin.installed_sha = params[:installed_sha]
    plugin.git_branch = params[:git_branch]
    plugin.contact_emails = params[:contact_emails]
    
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
      
      tag_name = plugin_name.gsub("discourse-", "")
  
      report_tags = []
  
      report_tags = report_tags.concat(SiteSetting.plugin_manager_issue_management_site_issue_tags.split('|')).concat([tag_name])
  
      body = {
        title: "Plugin '#{plugin_name}' almost prevented a rebuild on '#{SiteSetting.title}'",
        raw:  "The Plugin '#{plugin_name}' almost prevented a rebuild on site: [#{SiteSetting.title}](#{Discourse.base_url}) so has been isolated - please take a look",
        tags: report_tags,
        category: SiteSetting.plugin_manager_issue_management_site_issue_category,
        archetype: "regular"
      }
  
      unless SiteSetting.plugin_manager_issue_management_site_base_url.nil? || SiteSetting.plugin_manager_issue_management_site_api_token.nil? || SiteSetting.plugin_manager_issue_management_site_api_user.nil?
        post_topic_result = Excon.post("#{SiteSetting.plugin_manager_issue_management_site_base_url}/posts", :headers => {"Content-Type" => "application/json", "Api-Username" => "#{SiteSetting.plugin_manager_issue_management_site_api_user}", "Api-Key" => "#{SiteSetting.plugin_manager_issue_management_site_api_token}"}, :body => body.to_json)
      end

      contacts = params[:contact_emails].split(",")

      external_contacts = contacts.reject do |contact|
        contact.include? 'thepavilion.io'
      end

      external_contacts = external_contacts.map(&:strip)

      external_contacts = external_contacts.join(",")

      Jobs.enqueue(:send_plugin_incompatible_notification_to_support,
        plugin: plugin_name,
        site: SiteSetting.title,
        contact_emails: external_contacts
      )
    end
  end
end

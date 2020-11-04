class DiscourseServerStatus::Plugins
  FOLDER = "plugins"
  INCOMPATIBLE_FOLDER = "plugins_incompatible"
  
  def initialize
  end
  
  def compatible
    @compatible ||= list_by_status(self.class.status[:compatible])
  end
    
  def incompatible
    @incompatible ||= list_by_status(self.class.status[:incompatible])
  end
  
  def list_by_status(status)
    PluginStoreRow.where("
      plugin_name = '#{DiscourseServerStatus::PLUGIN_NAME}' AND
      (value::json->>'status')::int = ?
    ", status).pluck(:value)
      .map do |value|
        begin
          JSON.parse(value)
        rescue JSON::ParserError
          {}
        end
      end
  end
  
  def set_from_local(status)
    folder = status == self.class.status[:compatible] ? FOLDER : INCOMPATIBLE_FOLDER 
    path = "#{Rails.root}/#{folder}"
    
    return unless File.directory?(path)
    
    Dir.each_child(path) do |folder|
      plugin_path = "#{path}/#{folder}"
      
      begin
        file = File.read("#{plugin_path}/plugin.rb")
      rescue
        #
      end
      
      if file.present?
        metadata = Plugin::Metadata.parse(file)
        
        if metadata.present? && 
          ::Plugin::Metadata::OFFICIAL_PLUGINS.exclude?(metadata.name)
          
          sha = nil
          branch = nil
          
          Dir.chdir(plugin_path) do
            sha = `git rev-parse HEAD`.strip
            branch = `git rev-parse --abbrev-ref HEAD`.strip
          end
                    
          set_plugin(
            name: metadata.name,
            url: metadata.url,
            installed_sha: sha,
            git_branch: branch,
            status: status
          )
        end
      end
    end
  end
  
  def self.set_all_from_local
    plugins = self.new
    plugins.set_from_local(self.status[:compatible])
    plugins.set_from_local(self.status[:incompatible])
  end
  
  def self.status
    @status ||= Enum.new(compatible: 1, incompatible: 2)
  end
  
  private
  
  def set_plugin(state)
    plugin_name = state[:name]
    current_state = get_plugin(plugin_name)
  
    if current_state[:status] != state[:status]
      handle_change(state)
    end

    new_state = current_state.merge(state)
    PluginStore.set(DiscourseServerStatus::PLUGIN_NAME, plugin_name, new_state)
  end
  
  def get_plugin(plugin_name)
    PluginStore.get(DiscourseServerStatus::PLUGIN_NAME, plugin_name) || {}
  end
  
  def handle_change(state)
    if state[:status] == self.class.status[:incompatible]
      Jobs.enqueue(:send_plugin_incompatible_notification,
        plugin: name,
        site: SiteSetting.title
      )
    end
  end
end
class DiscourseServerStatus::Plugins
  FOLDER = "plugins"
  INCOMPATIBLE_FOLDER = "plugins_incompatible"
  
  def initialize
  end
  
  def compatible
    @compatible ||= get_state_by_status('compatible')
  end
    
  def incompatible
    @incompatible ||= get_state_by_status('incompatible')
  end
  
  def get_state_by_status(status)
    PluginStoreRow.where("plugin_name = '#{build_plugin_name(status)}'")
      .pluck(:value)
      .map do |value|
        begin
          JSON.parse(value)
        rescue JSON::ParserError
          {}
        end
      end
  end
  
  def set_state_by_status(status)    
    path = "#{Rails.root}/#{status === "compatible" ? FOLDER : INCOMPATIBLE_FOLDER}"
    
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
                    
          set_plugin_state(status,
            name: metadata.name,
            url: metadata.url,
            installed_sha: sha,
            git_branch: branch
          )
        end
      end
    end
  end
  
  def self.after_initialize
    plugins = self.new
    plugins.set_state_by_status("compatible")
    plugins.set_state_by_status("incompatible")
  end
  
  private
  
  def set_plugin_state(status, state)
    PluginStore.set(build_plugin_name(status), state[:name], state)
  end
  
  def get_plugin_state(status, plugin_name)
    PluginStore.get(build_plugin_name(status), plugin_name)
  end
  
  def build_plugin_name(status)
    "#{DiscourseServerStatus::PLUGIN_NAME}-#{status}"
  end
end
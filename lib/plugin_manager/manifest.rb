class ::PluginManager::Manifest
  FOLDER = "plugins"
  INCOMPATIBLE_FOLDER = "plugins_incompatible"
  
  def self.status
    @status ||= Enum.new(active: 0, compatible: 1, incompatible: 2)
  end
  
  def active
    @active ||= ::PluginManager::Plugin.list_by('status', self.class.status[:active])
  end
  
  def compatible
    @compatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:compatible])
  end
    
  def incompatible
    @incompatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:incompatible])
  end
  
  def set_from_local(status)
    folder = status == self.class.status[:incompatible] ? INCOMPATIBLE_FOLDER : FOLDER 
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
          tests_host = nil
          
          Dir.chdir(plugin_path) do
            sha = `git rev-parse HEAD`.strip
            branch = `git rev-parse --abbrev-ref HEAD`.strip
            tests_host = PluginManager::TestHosts.detect
          end
          
          plugin_params = {
            url: metadata.url,
            contact_emails: metadata.contact_emails,
            installed_sha: sha,
            git_branch: branch,
            status: status
          }
                    
          if tests_host
            plugin_params[:tests_host] = tests_host
          end
                  
          ::PluginManager::Plugin.set(metadata.name, plugin_params)
        end
      end
    end
  end
  
  def self.update_status
    manifest = self.new
    manifest.set_from_local(self.status[:active])
    manifest.set_from_local(self.status[:incompatible])    
    
    Jobs.enqueue(:fetch_plugin_tests_status)
  end
end
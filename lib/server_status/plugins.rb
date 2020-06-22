class DiscourseServerStatus::Plugins
  PLUGIN_PATH = "#{Rails.root}/plugins"
  INCOMPATIBLE_PLUGIN_PATH = "#{Rails.root}/plugins_incompatible"
  
  def initialize
  end
  
  def stats
    gather_stats(PLUGIN_PATH)
  end
    
  def incompatible_stats
    gather_stats(INCOMPATIBLE_PLUGIN_PATH)
  end
  
  def gather_stats(path)
    stats = []
    
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
                    
          stats.push(
            name: metadata.name,
            url: metadata.url,
            installed_sha: sha,
            git_branch: branch,
          )
        end
      end
    end
    
    stats
  end
end
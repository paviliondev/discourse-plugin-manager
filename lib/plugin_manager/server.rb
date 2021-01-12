# frozen_string_literal: true

class ::PluginManager::Server
  def self.get_status
    status = ::DiscourseUpdates.check_version
    
    if status.installed_sha
      updated_at_cmd = "git show -s --format=%ci #{status.installed_sha}"
      status.updated_at = Discourse.try_git(updated_at_cmd, 'unknown')
    end
    
    status
  end
end
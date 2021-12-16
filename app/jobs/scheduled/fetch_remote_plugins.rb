# frozen_string_literal: true
module Jobs
  class FetchRemotePlugins < ::Jobs::Scheduled
    every 1.days

    def execute(args)
      ::PluginManager::Manifest.update_remote_plugins
    end
  end
end

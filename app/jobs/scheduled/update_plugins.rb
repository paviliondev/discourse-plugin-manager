# frozen_string_literal: true
module Jobs
  class UpdatePlugins < ::Jobs::Scheduled
    every 1.days

    def execute(args)
      ::PluginManager::Plugin.update_plugins
    end
  end
end

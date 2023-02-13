# frozen_string_literal: true
module Jobs
  class UpdatePluginTestsStatuses < ::Jobs::Scheduled
    every 10.minutes

    def execute(args)
      ::PluginManager::Plugin.update_test_statuses
    end
  end
end

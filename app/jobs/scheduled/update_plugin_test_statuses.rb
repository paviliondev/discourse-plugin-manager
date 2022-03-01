# frozen_string_literal: true
module Jobs
  class UpdatePluginTestsStatuses < ::Jobs::Scheduled
    every 1.hours

    def execute(args)
      ::PluginManager::Plugin.update_test_statuses
    end
  end
end

# frozen_string_literal: true
module Jobs
  class FetchPluginTestsStatus < ::Jobs::Scheduled
    every 1.hours

    def execute(args)
      ::PluginManager::Manifest.update_test_status
    end
  end
end

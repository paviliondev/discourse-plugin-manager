# frozen_string_literal: true

task "plugin_manager:update_test_statuses" => [:environment] do |_, args|
  PluginManager::Plugin.update_test_statuses
end

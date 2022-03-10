# frozen_string_literal: true

task "plugin_manager:update_test_statuses" => [:environment] do |_, args|
  api_key = SiteSetting.plugin_manager_api_key
  unless api_key.present?
    puts "ERROR: `plugin_manager_api_key` site setting is not set"
    exit 1
  end

  plugins = PluginGuard::Status.all_plugins
  status = PluginGuard::Status.new(plugins)

  unless status.update
    puts status.errors.full_messages.join(", ")
    exit 1
  end

  puts "SUCCESS: Updated all registered plugins."
  exit 0
end

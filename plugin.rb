# name: discourse-plugin-manager-server
# about: Serverside functionality for Pavilion's Plugin Manager
# version: 0.1.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-plugin-manager-server

register_asset "stylesheets/common/plugin-manager.scss"
register_asset "stylesheets/mobile/plugin-manager.scss", :mobile

if respond_to?(:register_svg_icon)
  register_svg_icon "bug"
  register_svg_icon "info-circle"
end

# add_admin_route "admin.plugin_manager.title", "plugin-manager"

after_initialize do
  %w(
    ../lib/plugin_manager/engine.rb
    ../lib/plugin_manager/manifest.rb
    ../lib/plugin_manager/plugin.rb
    ../lib/plugin_manager/server.rb
    ../lib/plugin_manager/test_manager.rb
    ../lib/plugin_manager/test_hosts.rb
    ../lib/plugin_manager/update.rb
    ../mailers/plugin_mailer.rb
    ../app/jobs/regular/fetch_plugin_tests_status.rb
    ../app/jobs/regular/send_plugin_incompatible_notification.rb
    ../app/controllers/plugin_manager/status_controller.rb
    ../app/serializers/plugin_manager/update_serializer.rb
    ../config/routes.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  PluginManager::Manifest.update_status
end
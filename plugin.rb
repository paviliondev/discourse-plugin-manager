# name: discourse-plugin-manager-server
# about: Serverside functionality for Pavilion's Plugin Manager
# version: 0.1.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-plugin-manager-server

register_asset "stylesheets/common/plugin-manager.scss"
register_asset "stylesheets/mobile/plugin-manager.scss", :mobile

register_svg_icon "bug"
register_svg_icon "far-check-circle"
register_svg_icon "far-times-circle"
register_svg_icon "code-branch"
register_svg_icon "vial"
register_svg_icon "building"
register_svg_icon "far-life-ring"
register_svg_icon "far-question-circle"

after_initialize do
  %w(
    ../lib/plugin_manager/engine.rb
    ../mailers/plugin_mailer.rb
    ../app/jobs/scheduled/fetch_plugin_tests_status.rb
    ../app/jobs/regular/send_plugin_incompatible_notification.rb
    ../app/controllers/plugin_manager/plugin_controller.rb
    ../app/controllers/plugin_manager/status_controller.rb
    ../app/serializers/plugin_manager/discourse_serializer.rb
    ../app/serializers/plugin_manager/log_serializer.rb
    ../app/serializers/plugin_manager/basic_plugin_serializer.rb
    ../app/serializers/plugin_manager/plugin_serializer.rb
    ../app/serializers/plugin_manager/owner_serializer.rb
    ../config/routes.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end

  PluginManager::Manifest.update_plugin_status
  PluginManager::Manifest.update_test_status
end
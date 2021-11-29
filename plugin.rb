# frozen_string_literal: true
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
  if Rails.env.test?
    %w(
      ../lib/plugin_guard.rb
      ../lib/plugin_guard/extensions/discourse.rb
      ../lib/plugin_guard/extensions/plugin_instance.rb
      ../lib/plugin_guard/error.rb
      ../lib/plugin_guard/handler.rb
      ../lib/plugin_guard/log.rb
      ../lib/plugin_manager.rb
      ../lib/plugin_manager/discourse.rb
      ../lib/plugin_manager/manifest.rb
      ../lib/plugin_manager/notifier.rb
      ../lib/plugin_manager/plugin.rb
      ../lib/plugin_manager/test_host.rb
      ../lib/plugin_manager/test_host/github.rb
      ../lib/plugin_manager/test_manager.rb
      ../lib/plugin_manager/update.rb
      ../lib/plugin_manager/repository_owner.rb
      ../lib/plugin_manager/repository_host.rb
      ../lib/plugin_manager/repository_host/github.rb
      ../lib/plugin_manager/repository_manager.rb
    ).each do |path|
      load File.expand_path(path, __FILE__)
    end

    FileUtils.mv('../lib/plugin_initialization_guard.rb', '../../../lib/plugin_initialization_guard.rb', force: true)
  end

  %w(
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

  PluginManager::Plugin.add_extra_metadata

  unless Rails.env.test?
    PluginManager::Manifest.update_plugin_status
    PluginManager::Manifest.update_test_status
  end
end

# name: discourse-server-status
# about: Display public information about server and plugin status
# version: 0.1.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-server-status

register_asset "stylesheets/common/server-status.scss"
register_asset "stylesheets/mobile/server-status.scss", :mobile

if respond_to?(:register_svg_icon)
  register_svg_icon "bug"
  register_svg_icon "info-circle"
end

after_initialize do
  %w(
    ../lib/server_status/engine.rb
    ../lib/server_status/plugins.rb
    ../lib/server_status/update.rb
    ../app/jobs/regular/send_plugin_incompatible_notification.rb
    ../app/controllers/server_status/status_controller.rb
    ../app/serializers/server_status/update_serializer.rb
    ../config/routes.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end
  
  DiscourseServerStatus::Plugins.set_all_from_local
end
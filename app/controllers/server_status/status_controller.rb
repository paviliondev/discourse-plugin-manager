class DiscourseServerStatus::StatusController < ::ApplicationController
  def show
    plugins = DiscourseServerStatus::Plugins.new
    
    render_json_dump(
      update: serialized_update,
      discourse: ::DiscourseUpdates.check_version,
      plugins: plugins.stats,
      incompatible_plugins: plugins.incompatible_stats
    )
  end
  
  def serialized_update
    if update_topic = DiscourseServerStatus::Update.current
      DiscourseServerStatus::UpdateSerializer.new(update_topic, root: false)
    end
  end
end
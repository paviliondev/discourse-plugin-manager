# frozen_string_literal: true

class PluginManager::StatusController < ::ApplicationController
  def show
    plugins = PluginManager::Manifest.new
    
    render_json_dump(
      update: serialized_update,
      discourse: PluginManager::Server.get_status,
      plugins: plugins.active,
      compatible_plugins: plugins.compatible,
      incompatible_plugins: plugins.incompatible
    )
  end
  
  def serialized_update
    if update_topic = PluginManager::Update.current
      PluginManager::UpdateSerializer.new(update_topic, root: false)
    end
  end
end
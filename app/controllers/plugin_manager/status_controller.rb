# frozen_string_literal: true

class PluginManager::StatusController < ::ApplicationController
  def index
    manifest = PluginManager::Manifest.new

    render_json_dump(
      discourse: PluginManager::DiscourseSerializer.new(manifest.discourse, root: false),
      plugins: ActiveModel::ArraySerializer.new(manifest.plugins, each_serializer: PluginManager::PluginSerializer, root: false)
    )
  end
end
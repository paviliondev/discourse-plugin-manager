# frozen_string_literal: true

class PluginManager::StatusController < ::ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:show]

  def index
    manifest = PluginManager::Manifest.new

    render_json_dump(
      discourse: PluginManager::DiscourseSerializer.new(manifest.discourse, root: false),
      plugins: ActiveModel::ArraySerializer.new(manifest.plugins, each_serializer: PluginManager::PluginSerializer, root: false)
    )
  end

  def show
    plugin = PluginManager::Plugin.get(params[:plugin_name])
    raise Discourse::InvalidParameters.new(:plugin_name) if plugin.blank?

    render_serialized(plugin, PluginManager::BasicPluginSerializer, root: false)
  end
end
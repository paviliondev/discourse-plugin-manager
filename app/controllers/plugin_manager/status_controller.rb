# frozen_string_literal: true

class PluginManager::StatusController < ::ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:show]

  def show
    plugin = PluginManager::Plugin.get(params[:plugin_name])
    raise Discourse::InvalidParameters.new(:plugin_name) if plugin.blank?

    render_serialized(plugin, PluginManager::BasicPluginSerializer, root: false)
  end
end

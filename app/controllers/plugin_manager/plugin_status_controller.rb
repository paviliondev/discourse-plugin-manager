# frozen_string_literal: true

class PluginManager::PluginStatusController < ::ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:show, :update]
  before_action :ensure_api, only: [:update]

  def show
    @plugin = PluginManager::Plugin.get(params.permit(:plugin_name).dasherize)
    raise Discourse::InvalidParameters.new(:plugin_name) if !@plugin

    render_serialized(@plugin, PluginManager::BasicPluginSerializer, root: false)
  end

  def update
    @plugins = params.permit(plugins: {})

    unless current_user.plugin_registered?(request.domain, plugin_name)
      raise Discourse::InvalidAccess.new("you are not authorized to update #{@plugin.name} status'")
    end

    status = params[:status]
    unless ::PluginManager::Manifest.status.values.include?(status)
      raise Discourse::InvalidAccess.new("not a valid plugin status")
    end

    message, backtrace = params.permit(:message, :backtrace)

    PluginManager::Log.add(
      plugin_name: @plugin.name,
      status: status,
      message: message,
      backtrace: backtrace,
    )

    if ::PluginManager::Plugin.set(@plugin.name, status: status)
      render json: success_json
    else
      render json: failed_json
    end
  end

  def ensure_api
    unless is_user_api? && current_user.present?
      raise Discourse::InvalidAccess.new('plugin statuses can only be updated via authorized api requests')
    end
  end
end

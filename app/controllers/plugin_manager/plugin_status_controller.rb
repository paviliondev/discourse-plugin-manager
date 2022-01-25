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
    plugins = params.permit(plugins: [:name, :status, :message, :backtrace])
    domain = params[:domain]

    registered_plugins =
      plugins.reduce do |result, plugin|
        auth_site = is_api? && ::PluginManager::Plugin.exist?(plugin['name'])
        auth_user = current_user.plugin_registered?(domain, plugin['name'])

        result.push(plugin.symbolize_keys) if auth_site || auth_user
        result
      end

    unless registered_plugins.any?
      raise Discourse::InvalidAccess.new("you are not authorized to update the status of any of these plugins")
    end

    registered_plugins = registered_plugins.select do |plugin|
      ::PluginManager::Manifest.status.values.include?(plugin[:status])
    end

    unless registered_plugins.any?
      raise Discourse::InvalidParameters.new("no valid plugin statuses")
    end

    registered_plugins.each do |plugin|
      logged = PluginManager::Log.add(plugin)
      updated = PluginManager::Plugin.set(plugin[:name], status: plugin[:status])
      errors.push(plugin[:name]) unless logged && updated
    end

    if errors.any?
      render json: failed_json.merge(plugins: errors)
    else
      render json: success_json
    end
  end

  def validate_key
    valid = false

    if is_api?
      api_key = request.env[Auth::DefaultCurrentUserProvider::HEADER_API_KEY]
      api_key_record = ApiKey.active.with_key(api_key).first
      valid = api_key_record&.api_key_scopes&.any? { |scope| scope.resource == "plugin_manager" && scope.action == "status" }
    end

    if is_user_api?
      user_api_key = request.env[Auth::DefaultCurrentUserProvider::USER_API_KEY]
      hashed_user_api_key = ApiKey.hash_key(user_api_key)
      user_api_key_record = UserApiKey.active.where(key_hash: hashed_user_api_key).first
      valid = user_api_key_record&.scopes&.any? { |scope| scope.name == "discourse-plugin-manager:plugin_user" }
    end

    if valid
      render json: success_json
    else
      render status: 400, json: failed_json
    end
  end

  protected

  def ensure_api
    unless is_api? || (is_user_api? && current_user.present?)
      raise Discourse::InvalidAccess.new('plugin statuses can only be updated via authorized api requests')
    end
  end
end

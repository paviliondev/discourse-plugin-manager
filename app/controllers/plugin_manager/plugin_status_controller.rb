# frozen_string_literal: true

class PluginManager::PluginStatusController < ::ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token
  before_action :ensure_api, only: [:update]

  def index
    plugins = params.permit(plugins: [:name, :branch, :discourse_branch])

    unless plugins[:plugins].present?
      raise Discourse::InvalidParameters.new(:plugins)
    end

    plugin_list = plugins.to_h[:plugins]
    status_keys = plugin_list.reduce([]) do |result, plugin|
      if ::PluginManager::Plugin.exists?(plugin['name'])
        result.push(
          PluginManager::Plugin::Status.status_key(
            plugin['name'],
            plugin['branch'],
            plugin['discourse_branch']
          )
        )
      end
      result
    end

    page = params[:page].to_i
    result = ::PluginManager::Plugin::Status.list(keys: status_keys, page: page)

    response = {
      statuses: ActiveModel::ArraySerializer.new(result.statuses, each_serializer: PluginManager::PluginStatusSerializer).as_json,
      total: result.total
    }

    if result.total > PluginManager::Plugin::Status::PAGE_LIMIT
      response[:next_page] = page + 1
    end

    render_json_dump(response)
  end

  def show
    attrs = params.permit(:plugin_name, :discourse_branch, :branch)
    status = ::PluginManager::Plugin::Status.get(attrs[:plugin_name], attrs[:discourse_branch], attrs[:branch])
    raise Discourse::InvalidParameters.new(:plugin_name) if !status

    render_serialized(@status, PluginManager::PluginStatusSerializer, root: false)
  end

  def update
    domain = params[:domain]
    plugins = params.permit(plugins: [:name, :branch, :sha, :status, :message, :backtrace])
      .to_h[:plugins]
      .map(&:with_indifferent_access)
      .select { |plugin| [:name, :branch, :sha, :status].all? { |key| plugin[key].present? } }

    unless plugins.any?
      raise Discourse::InvalidParameters.new(:plugins)
    end

    discourse = params.permit(discourse: [:branch, :sha])
      .to_h[:discourse]
      .with_indifferent_access

    unless discourse[:sha].present? && discourse[:branch].present?
      raise Discourse::InvalidParameters.new(:discourse)
    end

    registered_plugins =
      plugins.reduce([]) do |result, plugin|
        auth_site = is_api? && ::PluginManager::Plugin.exists?(plugin[:name])
        auth_user = current_user.plugin_registered?(domain, plugin[:name])

        result.push(plugin.symbolize_keys) if auth_site || auth_user
        result
      end

    unless registered_plugins.any?
      raise Discourse::InvalidAccess.new("you are not authorized to update the status of any of these plugins")
    end

    registered_plugins = [*registered_plugins].select do |plugin|
      ::PluginManager::Plugin::Status.statuses.values.include?(plugin[:status].to_i)
    end

    unless registered_plugins.any?
      raise Discourse::InvalidParameters.new("no valid plugin statuses")
    end

    Rails.logger.warn("Plugin status update received: #{registered_plugins.inspect}")

    errors = []
    updated = []
    registered_plugins.each do |plugin|
      git = {
        branch: plugin[:branch],
        sha: plugin[:sha],
        discourse_branch: discourse[:branch],
        discourse_sha: discourse[:sha]
      }
      attrs = {
        status: plugin[:status].to_i,
        skip_git_check: current_user.staff?,
        message: plugin[:message],
        backtrace: plugin[:backtrace]
      }
      result = PluginManager::Plugin::Status.update(plugin[:name], git, attrs)

      Rails.logger.warn("Plugin status update result: #{result.inspect}")

      if result.errors.any?
        errors << {
          plugin: plugin[:name],
          errors: result.errors
        }
      else
        updated << plugin[:name]
      end
    end

    json = registered_plugins.size === errors.size ? failed_json : success_json
    json = json.merge(errors: errors) if errors.any?
    json = json.merge(updated: updated) if updated.any?

    render json: json
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

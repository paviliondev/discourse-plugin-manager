# frozen_string_literal: true

class PluginManager::PluginUserController < ::ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token, only: [:register]
  before_action :ensure_api, only: [:register]

  def index
  end

  def registered
    render_serialized(current_user.registered_plugins, PluginManager::PluginUserSerializer)
  end

  def register
    plugins = params[:plugins]
    domain = params[:domain]

    raise Discourse::InvalidParameters.new(:plugins) if plugins.blank?
    raise Discourse::InvalidParameters.new(:domain) if domain.blank?

    registered_plugins = current_user.register_plugins(domain, plugins)

    if registered_plugins.any?
      render json: success_json.merge(
        user_id: current_user.id,
        domain: domain,
        plugins: registered_plugins.map(&:name),
        updated_at: current_user.registered_plugins_updated_at(domain)
      )
    else
      render json: failed_json
    end
  end

  protected

  def ensure_api
    unless is_user_api? && current_user.present?
      raise Discourse::InvalidAccess.new('plugin registrations can only be made via authorized api requests')
    end
  end
end

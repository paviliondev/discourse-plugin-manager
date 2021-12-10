# frozen_string_literal: true
class PluginManager::PluginController < ::ApplicationController
  before_action :ensure_admin, only: [:update, :delete]

  def index
    plugins = PluginManager::Plugin.list(
      page: params[:page].to_i,
      filter: params[:filter],
      order: params[:order],
      asc: params[:asc]
    )
    render_serialized(plugins, PluginManager::PluginSerializer, root: 'plugins')
  end

  def retrieve
    params.require(:url)
    url = params[:url]
    branch = params[:branch] || 'main'
    result = PluginManager::Plugin.get_from_url(url, branch)

    if result.success
      cookies["#{result.plugin[:name]}-url"] = url
      render json: success_json.merge(plugin: result.plugin)
    else
      render json: failed_json.merge(error: result.error)
    end
  end

  def save
    name = params[:plugin_name].dasherize
    plugin = PluginManager::Plugin.get(name)
    url = plugin.url || cookies["#{name}-url"]

    if name && url
      cookies["#{name}-url"] = nil
    else
      raise Discourse::InvalidParameters.new(:plugin_name)
    end

    attrs = params.require(:plugin).permit(
      :support_url,
      :try_url,
      :authors,
      :about,
      :version,
      :contact_emails,
      :test_host,
      :status
    )
    attrs[:url] = url

    if PluginManager::Plugin.set(name, attrs)
      plugin = PluginManager::Plugin.get(name)
      serialized_plugin = PluginManager::PluginSerializer.new(plugin, root: false).as_json
      render json: success_json.merge(plugin: serialized_plugin)
    else
      render json: failed_json
    end
  end

  def delete
    name = params[:plugin_name].dasherize

    if PluginManager::Plugin.remove(name)
      render json: success_json.merge(plugin_name: name)
    else
      render json: failed_json
    end
  end
end

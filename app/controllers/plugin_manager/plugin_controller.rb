# frozen_string_literal: true

class PluginManager::PluginController < ::ApplicationController
  before_action :ensure_admin, only: [:retrieve, :save, :delete]

  def index
    plugins = PluginManager::Plugin.list(
      page: params[:page].to_i,
      filter: params[:filter],
      order: params[:order],
      asc: params[:asc]
    )

    branch = params[:branch]
    discourse_branch = params[:discourse_branch]
    status_keys = plugins.map do |plugin|
      PluginManager::Plugin::Status.status_key(
        plugin.name,
        discourse_branch,
        branch
      )
    end
    statuses = PluginManager::Plugin::Status.list(keys: status_keys)

    status_map = statuses.statuses.reduce({}) do |result, status|
      result[status.name] = status
      result
    end

    plugins.each do |plugin|
      plugin.status = statuses[plugin.name]
    end

    render_serialized(plugins, PluginManager::PluginSerializer, root: 'plugins')
  end

  def category
    plugins = ::PluginManager::Plugin.list_by('category_id', params[:category_id])
    render_serialized(plugins.first, PluginManager::PluginSerializer, root: 'plugin')
  end

  def retrieve
    params.require(:url)
    url = params[:url]
    result = PluginManager::Plugin.retrieve_from_url(url, params[:branch])

    if result.success
      result.plugin[:test_host] = PluginManager::TestHost.detect(url)
      result.plugin[:status] = PluginManager::Plugin::Status.statuses[:unknown]

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
      :authors,
      :about,
      :version,
      :contact_emails,
      :test_host,
      :status,
      :branch,
      :discourse_branch
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

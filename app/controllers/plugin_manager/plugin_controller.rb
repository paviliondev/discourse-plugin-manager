# frozen_string_literal: true

class PluginManager::PluginController < ::ApplicationController
  before_action :ensure_staff, only: [:retrieve, :save, :delete]
  before_action :find_plugins, only: [:index, :show, :category]

  def index
    render_json_dump(
      branch: discourse_branch,
      plugins: serialize_data(@plugins, PluginManager::PluginSerializer)
    )
  end

  def show
    render_json_dump(
      branch: discourse_branch,
      plugin: serialize_data(@plugins.first, PluginManager::PluginSerializer, root: false)
    )
  end

  def category
    render_json_dump(
      branch: discourse_branch,
      plugin: serialize_data(@plugins.first, PluginManager::PluginSerializer, root: false)
    )
  end

  def retrieve
    params.require(:url)
    url = params[:url]
    result = PluginManager::Plugin.retrieve_from_url(url)

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
      :test_host
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

  protected

  def find_plugins
    if action_name === 'category'
      @plugins = PluginManager::Plugin.list_by('category_id', params[:category_id])
    elsif action_name === 'show'
      @plugins = [PluginManager::Plugin.get(params[:plugin_name])]
    else
      @plugins = PluginManager::Plugin.list(
        tags: params[:tags],
        all_tags: ActiveRecord::Type::Boolean.new.cast(params[:all_tags]),
        page: params[:page].to_i,
        filter: params[:filter],
        order: params[:order],
        asc: params[:asc]
      )
    end

    map_status_to_plugins
  end

  def discourse_branch
    @discourse_branch ||= params[:branch] || 'tests-passed'
  end

  def map_status_to_plugins
    @plugins.each do |plugin|
      if status = status_map[plugin.name]
        plugin.status = status
      else
        plugin.status = PluginManager::Plugin::Status.placeholder_status(plugin, discourse_branch)
      end
    end
  end

  def status_map
    @status_map ||= begin
      status_map = PluginManager::Plugin::Status.list(discourse_branch: discourse_branch)
        .statuses
        .reduce({}) do |result, status|
          result[status.name] = status
          result
        end
    end
  end
end

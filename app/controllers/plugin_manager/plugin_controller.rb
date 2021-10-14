# frozen_string_literal: true
class PluginManager::PluginController < Admin::AdminController
  def index
    plugins = PluginManager::Plugin.list(
      page: params[:page].to_i,
      filter: params[:filter],
      order: params[:order],
      asc: params[:asc]
    )
    render_serialized(plugins, PluginManager::PluginSerializer, root: 'plugins')
  end

  def update
    name = params[:plugin_name].dasherize
    plugin = ::PluginManager::Plugin.get(name)

    if plugin.from_file
      attrs = params.require(:plugin).permit(
        :support_url,
        :test_url
      )
    else
      attrs = params.require(:plugin)
        .permit(
          :url,
          :authors,
          :about,
          :version,
          :contact_emails,
          :test_host,
          :support_url,
          :test_url,
          :status
        )

      if attrs[:status].to_i === PluginManager::Manifest.status[:tests_failing]
        attrs[:status] = nil
      end
    end

    if PluginManager::Plugin.set(name, attrs)
      render json: success_json.merge(
        plugin: PluginManager::Plugin.get(name)
      )
    else
      render json: failed_json
    end
  end

  def delete
    name = params[:plugin_name].dasherize

    if PluginManager::Plugin.remove(name)
      render json: success_json
    else
      render json: failed_json
    end
  end
end
# frozen_string_literal: true
class PluginManager::PluginController < Admin::AdminController
  def index
    render_serialized(PluginManager::Plugin.list, PluginManager::PluginSerializer, root: 'plugins')
  end

  def update
    plugin = ::PluginManager::Plugin.get(params[:name])

    if plugin.from_file
      attrs = params.require(:plugin).permit(:support_url)
    else
      attrs = params.require(:plugin)
        .permit(
          :name,
          :url,
          :authors,
          :about,
          :version,
          :contact_emails,
          :test_host,
          :support_url,
          :status
        )

      if attrs[:status].to_i === PluginManager::Manifest.status[:tests_failing]
        attrs[:status] = nil
      end
    end

    if PluginManager::Plugin.set(attrs)
      render json: success_json.merge(
        plugin: PluginManager::Plugin.get(params[:name])
      )
    else
      render json: failed_json
    end
  end

  def destroy
    params.require(:name)

    if PluginManager::Plugin.remove(params[:name])
      render json: success_json
    else
      render json: failed_json
    end
  end
end
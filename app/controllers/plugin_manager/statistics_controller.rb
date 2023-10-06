# frozen_string_literal: true

class PluginManager::StatisticsController < ApplicationController
  skip_before_action :check_xhr, :preload_json, :verify_authenticity_token

  def create
    received_at = Time.now

    if discourse = DiscoursePluginStatisticsDiscourse.find_by(host: discourse_params[:host])
      discourse.update!(discourse_params)
    else
      discourse = DiscoursePluginStatisticsDiscourse.create!(discourse_params)
    end
    raise Discourse::InvalidParameters.new('invalid discourse') unless discourse

    plugin_params[:plugins].each do |plugin|
      if ::PluginManager::Plugin.exists?(plugin[:name])
        DiscoursePluginStatisticsPlugin.create!(
          received_at: received_at,
          discourse_id: discourse.id,
          **plugin.to_h
        )
      end
    end

    render json: success_json
  end

  protected

  def discourse_params
    params.require(:discourse).permit(:host, :branch, :sha)
  end

  def plugin_params
    params.require(:plugins)
    params.permit(plugins: [:name, :branch, :sha, :url, data: {}])
  end
end

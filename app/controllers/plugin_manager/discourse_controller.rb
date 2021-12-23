# frozen_string_literal: true

class PluginManager::DiscourseController < ::ApplicationController
  def index
    render_serialized(::PluginManager::Discourse.new, PluginManager::DiscourseSerializer)
  end
end

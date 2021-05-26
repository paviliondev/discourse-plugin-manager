# frozen_string_literal: true

class ::PluginGuard::Handler
  attr_reader :plugin_guard
  
  def initialize(plugin_guard)
    @plugin_guard = plugin_guard
  end
  
  def perform(message, backtrace, type)
    log(message, backtrace, type)
    
    if type === 'error'
      clean_up_assets
      move_to_incompatible_folder
    end
  end
  
  def move_to_incompatible_folder
    FileUtils.mv(@plugin_guard.path, 'plugins_incompatible', force: true)
  end
  
  def clean_up_assets
    Discourse.plugins.reject! do |plugin|
      plugin.name == @plugin_guard.metadata.name
    end
    Rails.configuration.assets.paths.reject! do |path|
      path.include?(@plugin_guard.path.to_s)
    end
    Rails.configuration.assets.precompile.reject! do |file|
      @plugin_guard.precompiled_assets.include?(file) || (
        file.is_a?(String) && file.include?(@plugin_guard.metadata.name)
      )
    end
  end

  def log(message, backtrace, type)
    PluginGuard::Logs.new(@plugin_guard).add(message, backtrace, type)
  end
end
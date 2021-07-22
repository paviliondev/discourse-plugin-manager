# frozen_string_literal: true

class ::PluginGuard::Handler
  attr_reader :plugin,
              :plugin_dir

  def initialize(plugin_name, plugin_dir)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
    @plugin_dir = plugin_dir.to_s
  end

  def perform(message, backtrace, precompiled_assets)
    clean_up_assets(precompiled_assets)
    move_to(PluginManager::Manifest::INCOMPATIBLE_FOLDER)
    log(message, backtrace) if @plugin.compatible? && message.present?
  end

  def move_to(dir)
    plugin_dir = @plugin_dir.dup
    move_to_dir = plugin_dir.sub(/\/#{PluginManager::Manifest::FOLDER}\//, "/#{dir}/")
    FileUtils.rm_rf(move_to_dir)
    FileUtils.mv(@plugin_dir, move_to_dir, force: true)
  end

  def clean_up_assets(precompiled_assets)
    Discourse.plugins.reject! do |plugin|
      plugin.name == @plugin.name
    end
    Rails.configuration.assets.paths.reject! do |path|
      path.include?(@plugin_dir)
    end
    Rails.configuration.assets.precompile.reject! do |file|
      precompiled_assets.include?(file) || (
        file.is_a?(String) && file.include?(@plugin.name)
      )
    end
  end

  def log(message, backtrace)
    PluginGuard::Log.add(
      plugin_name: @plugin.name,
      message: message,
      backtrace: backtrace,
      type: 'error'
    )
  end
end
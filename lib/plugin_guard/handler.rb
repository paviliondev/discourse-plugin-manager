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
    move_to(PluginManager.incompatible_dir)
    log(message, backtrace) if message.present?
  end

  protected

  def move_to(dir)
    plugin_dir = @plugin_dir.dup
    return unless File.exists?(plugin_dir)
    move_to_dir = plugin_dir.reverse.sub(PluginManager.compatible_dir.reverse, dir.reverse).reverse
    FileUtils.mv(@plugin_dir, move_to_dir, force: true)
  end

  def clean_up_assets(precompiled_assets)
    Discourse.plugins.reject! { |plugin| plugin.name == @plugin.name }
    Rails.configuration.assets.paths.reject! { |path| path.include?(@plugin_dir) }
    Rails.configuration.assets.precompile.reject! do |file|
      precompiled_assets.include?(file) || (
        file.is_a?(String) && file.include?(@plugin.name)
      )
    end
    I18n.load_path.reject! { |file| file.include?(@plugin.name) }
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

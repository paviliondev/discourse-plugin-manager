# frozen_string_literal: true
module PluginManager
  NAMESPACE ||= 'plugin-manager'

  class Engine < ::Rails::Engine
    engine_name PluginManager::NAMESPACE
    isolate_namespace PluginManager
  end

  def self.root_dir
    Rails.root
  end

  def self.compatible_dir
    'plugins'
  end

  def self.incompatible_dir
    'plugins_incompatible'
  end

  def self.run_shell_cmd(cmd, opts = {})
    stdout, stderr_str, status = Open3.capture3(cmd, opts)
    stderr_str.present? ? nil : stdout.strip
  end
end

require_relative 'plugin_manager/discourse.rb'
require_relative 'plugin_manager/manifest.rb'
require_relative 'plugin_manager/notifier.rb'
require_relative 'plugin_manager/plugin.rb'
require_relative 'plugin_manager/repository_host.rb'
require_relative 'plugin_manager/repository_host/github.rb'
require_relative 'plugin_manager/repository_manager.rb'
require_relative 'plugin_manager/repository_owner.rb'
require_relative 'plugin_manager/test_host.rb'
require_relative 'plugin_manager/test_host/github.rb'
require_relative 'plugin_manager/test_manager.rb'
require_relative 'plugin_manager/update.rb'
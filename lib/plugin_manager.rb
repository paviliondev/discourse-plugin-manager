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
end
module ::PluginManager
  class Engine < ::Rails::Engine
    engine_name 'server_status'
    isolate_namespace PluginManager
  end
  
  PLUGIN_NAME ||= 'plugin_manager'
end
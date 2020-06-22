module ::DiscourseServerStatus
  class Engine < ::Rails::Engine
    engine_name 'discourse_server_status'
    isolate_namespace DiscourseServerStatus
  end
  
  PLUGIN_NAME ||= 'server_status'
end
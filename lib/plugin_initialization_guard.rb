# frozen_string_literal: true

def plugin_initialization_guard(&block)
  begin
    block.call
  rescue => error
    plugins_directory = Rails.root + 'plugins'
    
    plugin_path = error.backtrace_locations.lazy.map do |location|
      Pathname.new(location.absolute_path)
        .ascend
        .lazy
        .find { |path| path.parent == plugins_directory }
    end.next
    
    raise unless plugin_path
    
    guard = ::PluginGuard.new(plugin_path)
    if guard
      guard.handle(message: error.message, backtrace: error.backtrace.join($/))
    else
      raise
    end
  end
end

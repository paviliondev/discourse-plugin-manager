# frozen_string_literal: true

require './lib/enum.rb'
require_relative "plugin_manager_store"
require_relative "plugin_guard"
require_relative "plugin_guard/extensions/discourse.rb"
require_relative "plugin_guard/extensions/plugin_instance.rb"
require_relative "plugin_manager"

@extensions_applied = false

def plugin_initialization_guard(&block)
  if !@extensions_applied
    Discourse.singleton_class.prepend PluginGuard::DiscourseExtension
    Plugin::Instance.prepend PluginGuard::PluginInstanceExtension
    @extensions_applied = true
  end

  begin
    block.call
  rescue => error
    PluginGuard::Error.handle(error)
  end
end

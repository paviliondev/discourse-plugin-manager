# frozen_string_literal: true

require_relative "plugin_guard"
require_relative "plugin_manager"

@extensions_applied = false

def plugin_initialization_guard(&block)
  source_location = block.source_location
  source_line = IO.readlines(block.source_location.first)[block.source_location.second]
  @activating_plugins = source_line.include?("activate_plugins")

  if @activating_plugins && !@extensions_applied
    #require './app/models/plugin_store_row.rb'
    #require './app/models/plugin_store.rb'
    #require './lib/enum.rb'
    #Dir["./lib/plugin_guard/**/*.rb"].each { |file| require file }
    #Dir["./lib/plugin_manager/**/*.rb"].each { |file| require file }
    #Discourse.singleton_class.prepend PluginGuard::DiscourseExtension
    #Plugin::Instance.prepend PluginGuard::PluginInstanceExtension

    @extensions_applied = true
  end

  begin
    block.call
  rescue => error
    PluginGuard::Error.handle(error)
  end
end

# frozen_string_literal: true

require_relative ('../../app/models/plugin_store_row.rb')
require_relative ('../../app/models/plugin_store.rb')

class ::PluginGuard::Logs
  attr_reader :plugin_guard
  
  def initialize(plugin_guard)
    @plugin_guard = plugin_guard
  end
  
  def add(message, type)
    if log = PluginGuard::Log.new(@plugin_guard, message, type)
      logs = list
      logs.push(log.instance_values)
      PluginStore.set(PluginGuard::NAMESPACE, @plugin_guard.metadata.name, logs)
    end
  end
  
  def list
    PluginStore.get(PluginGuard::NAMESPACE, @plugin_guard.metadata.name) || []
  end
end
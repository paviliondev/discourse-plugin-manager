# frozen_string_literal: true

require_relative "plugin_guard"
require_relative "plugin_manager"

@extensions_applied = false

def plugin_initialization_guard(&block)
  @after_initialize = block.source.include?("notify_after_initialize")

  if !@after_initialize && !@extensions_applied
    Dir["./lib/plugin_guard/*.rb"].each { |file| require file }
    Dir["./lib/plugin_guard/**/*.rb"].each { |file| require file }
    db_name = "discourse_#{Rails.env}"

    begin
      db_exists = ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
        database: db_name,
        host: 'localhost'
      )
      table_exists = ActiveRecord::Base.connection.table_exists?('plugin_store_rows')
    rescue
      db_exists = false
      table_exists = false
    end

    if db_exists && table_exists
      require './app/models/plugin_store_row.rb'
      require './app/models/plugin_store.rb'
      require './lib/enum.rb'
      Dir["./lib/plugin_manager/*.rb"].each { |file| require file }
      Dir["./lib/plugin_manager/**/*.rb"].each { |file| require file }
      Discourse.singleton_class.prepend PluginGuard::DiscourseExtension
      Plugin::Instance.prepend PluginGuard::PluginInstanceExtension
    end

    @extensions_applied = true
  end

  begin
    block.call
  rescue => error
    PluginGuard::Error.handle(error)
  end

  if @extensions_applied
    ActiveRecord::Base.connection_handler.clear_active_connections!
  end
end

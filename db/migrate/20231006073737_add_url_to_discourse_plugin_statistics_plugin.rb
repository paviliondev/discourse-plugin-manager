# frozen_string_literal: true
class AddUrlToDiscoursePluginStatisticsPlugin < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_plugin_statistics_plugins, :url, :string
  end
end

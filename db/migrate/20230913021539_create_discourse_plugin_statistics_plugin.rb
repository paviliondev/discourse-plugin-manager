# frozen_string_literal: true
class CreateDiscoursePluginStatisticsPlugin < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_plugin_statistics_plugins do |t|
      t.integer :discourse_id
      t.datetime :received_at
      t.string :name
      t.string :branch
      t.string :sha
      t.json :data
      t.timestamps
    end
  end
end

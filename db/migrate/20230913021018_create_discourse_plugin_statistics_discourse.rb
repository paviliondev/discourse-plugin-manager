# frozen_string_literal: true
class CreateDiscoursePluginStatisticsDiscourse < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_plugin_statistics_discourses do |t|
      t.string :host
      t.string :branch
      t.string :sha
      t.timestamps
    end
  end
end

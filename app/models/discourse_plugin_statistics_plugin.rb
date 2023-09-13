# frozen_string_literal: true
class DiscoursePluginStatisticsPlugin < ActiveRecord::Base
  belongs_to :discourse, class_name: "DiscoursePluginStatisticsDiscourse", foreign_key: "discourse_id"
end

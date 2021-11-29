# frozen_string_literal: true
class ::PluginManager::Update
  attr_reader :category

  def initialize
    category_id = SiteSetting.plugin_manager_update_category_id
    @category ||= Category.find_by(id: category_id) if category_id
  end

  def current?
    category.present? && topic.present?
  end

  def topic
    @topic ||= TopicQuery.new(nil, category: category.id)
      .list_agenda
      .topics
      .reverse
      .first
  end
end

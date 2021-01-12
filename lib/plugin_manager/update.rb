class ::PluginManager::Update
  def self.current
    if SiteSetting.plugin_manager_update_category_id &&
      (category = Category.find_by(id: SiteSetting.plugin_manager_update_category_id)).present?
      TopicQuery.new(nil, 
        category: category.id,
      ).list_agenda.topics.reverse.first
    end
  end
end
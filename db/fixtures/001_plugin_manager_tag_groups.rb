unless TagGroup.exists?(name: PluginManager::Plugin::TAG_GROUP)
  tag_group = TagGroup.new(
    name: PluginManager::Plugin::TAG_GROUP,
    permissions: {
      staff: 1
    }
  )
  tag_group.save
end

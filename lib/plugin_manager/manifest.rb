class ::PluginManager::Manifest
  FOLDER = "plugins"
  INCOMPATIBLE_FOLDER = "plugins_incompatible"

  def self.status
    @status ||= Enum.new(
      compatible: 0,
      incompatible: 1
    )
  end

  def self.excluded
    @excluded ||= ::Plugin::Metadata::OFFICIAL_PLUGINS
  end

  def plugins
    @plugins ||= ::PluginManager::Plugin.list
  end

  def compatible
    @compatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:compatible])
  end

  def incompatible
    @incompatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:incompatible])
  end

  def discourse
    @discourse ||= ::PluginManager::Discourse.new
  end

  def set(status)
    folder = status == self.class.status[:incompatible] ? INCOMPATIBLE_FOLDER : FOLDER 
    path = "#{Rails.root}/#{folder}"
    return unless File.directory?(path)

    Dir.each_child(path) do |folder|
      plugin_path = "#{path}/#{folder}"
      PluginManager::Plugin.set_from_file(plugin_path)
    end
  end

  def self.update_plugin_status
    manifest = self.new
    manifest.set(self.status[:compatible])
    manifest.set(self.status[:incompatible])
  end

  def self.update_test_status
    ::PluginManager::Plugin.with_attr('test_host').each do |plugin|
      test_manager = PluginManager::TestManager.new(plugin.test_host)

      if test_manager.ready?
        test_manager.update(plugin.name)
      end
    end
  end
end
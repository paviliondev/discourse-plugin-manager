class ::PluginManager::Manifest
  FOLDER = "plugins"
  INCOMPATIBLE_FOLDER = "plugins_incompatible"

  def self.status
    @status ||= Enum.new(
      unknown: 0,
      compatible: 1,
      incompatible: 2,
      tests_failing: 3,
      recommended: 4
    )
  end

  def self.excluded
    @excluded ||= %w(
      discourse-details
      discourse-local-dates
      discourse-narrative-bot
      discourse-presence
      lazy-yt
      poll
      styleguide
    )
  end

  def plugins
    @plugins ||= ::PluginManager::Plugin.list
  end

  def recommended
    @compatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:recommended])
  end

  def compatible
    @compatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:compatible])
  end

  def incompatible
    @incompatible ||= ::PluginManager::Plugin.list_by('status', self.class.status[:incompatible])
  end

  def tests_failing
    @tests_failing ||= ::PluginManager::Plugin.list_by('status', self.class.status[:tests_failing])
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

  def self.working?(status)
    compatible?(status) || recommended?(status)
  end

  def self.not_working?(status)
    incompatible?(status) || tests_failing?(status)
  end

  def self.compatible?(status)
    status == ::PluginManager::Manifest.status[:compatible]
  end

  def self.incompatible?(status)
    status == ::PluginManager::Manifest.status[:incompatible]
  end

  def self.tests_failing?(status)
    status == ::PluginManager::Manifest.status[:tests_failing]
  end

  def self.recommended?(status)
    status == ::PluginManager::Manifest.status[:recommended]
  end

  def self.handle_status_change(plugin_name, old_status, new_status)
    if working?(old_status) && not_working?(new_status)
      notifier = ::PluginManager::Notifier.new(plugin_name)
      notifier.send
    end
  end
end
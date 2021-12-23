# frozen_string_literal: true
class ::PluginManager::Manifest
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
      docker_manager
      discourse-plugin-manager-server
      discourse-plugin-guard
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
    folder = status == self.class.status[:incompatible] ? PluginManager.incompatible_dir : PluginManager.compatible_dir
    path = "#{PluginManager.root_dir}/#{folder}"
    return unless File.directory?(path)

    Dir.each_child(path) do |dir|
      plugin_path = "#{path}/#{dir}"
      PluginManager::Plugin.set_from_file(plugin_path)
    end
  end

  def self.update_local_plugins
    manifest = self.new
    manifest.set(self.status[:compatible])
    manifest.set(self.status[:incompatible])
  end

  def self.update_remote_plugins
    ::PluginManager::Plugin.list_by('from_file', false).each do |plugin|
      result = PluginManager::Plugin.retrieve_from_url(plugin.url, plugin.git_branch)

      if result.success
        PluginManager::Plugin.set(plugin.name, result.plugin)
      end
    end
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
end

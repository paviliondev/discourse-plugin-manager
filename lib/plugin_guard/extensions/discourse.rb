module PluginGuard::DiscourseExtension
  def activate_plugins!
    @plugins = []

    Plugin::Instance.find_all("#{Rails.root}/plugins").each do |plugin_instance|
      version = plugin_instance.metadata.required_version || Discourse::VERSION::STRING
      plugin_name = plugin_instance.metadata.name

      unless Discourse.has_needed_version?(Discourse::VERSION::STRING, version)
        STDERR.puts "Could not activate #{plugin_name}, discourse does not meet required version (#{version})"
        next
      end

      if ::Plugin::Metadata::OFFICIAL_PLUGINS.include?(plugin_name)
        plugin_instance.activate!
        @plugins << plugin_instance
        next
      end

      plugin = ::PluginManager::Plugin.get_or_create(plugin_name)
      next unless plugin.present?

      if plugin.test_status == ::PluginManager::TestManager.status[:failing]
        guard = ::PluginGuard.new(plugin_instance.directory)
        guard.handle if guard.present?

        next
      end

      plugin_instance.activate!
      @plugins << plugin_instance
    end

    DiscourseEvent.trigger(:after_plugin_activation)
  end 
end
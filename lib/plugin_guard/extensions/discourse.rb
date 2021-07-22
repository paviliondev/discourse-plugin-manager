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

      begin
        plugin_instance.activate!
      rescue => error
        PluginGuard::Error.handle(error)
        next
      end

      @plugins << plugin_instance
    end

    DiscourseEvent.trigger(:after_plugin_activation)
  end 
end
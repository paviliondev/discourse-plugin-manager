module Jobs
  class SendPluginIncompatibleNotificationToSite < ::Jobs::Base
    def execute(args)
      [
        :plugin,
        :site
      ].each do |key|
        raise Discourse::InvalidParameters.new(key) unless args[key].present?
      end

      message = PluginMailer.incompatible_plugin_site(args[:plugin], args[:site], args[:contact_emails])
      Email::Sender.new(message, :incompatible_plugin_site).send
    end
  end

  class SendPluginIncompatibleNotificationToSupport < ::Jobs::Base
    def execute(args)
      [
        :plugin,
        :site,
        :contact_emails
      ].each do |key|
        raise Discourse::InvalidParameters.new(key) unless args[key].present?
      end

      message = PluginMailer.incompatible_plugin_support(args[:plugin], args[:site], args[:contact_emails])
      Email::Sender.new(message, :incompatible_plugin_support).send
    end
  end
end
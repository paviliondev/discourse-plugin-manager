# frozen_string_literal: true
module Jobs
  class SendPluginIncompatibleNotification < ::Jobs::Base
    def execute(args)
      [
        :plugin,
        :site,
        :contact_emails,
        :title,
        :raw
      ].each do |key|
        raise Discourse::InvalidParameters.new(key) unless args[key].present?
      end

      message = PluginMailer.incompatible_plugin_support(args)
      Email::Sender.new(message, :incompatible_plugin_support).send
    end
  end
end

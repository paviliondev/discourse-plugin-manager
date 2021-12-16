# frozen_string_literal: true
module Jobs
  class SendPluginNotification < ::Jobs::Base
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

      message = PluginMailer.plugin_support(args)
      Email::Sender.new(message, :plugin_support).send
    end
  end
end

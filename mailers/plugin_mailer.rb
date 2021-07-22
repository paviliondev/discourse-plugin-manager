class PluginMailer < ::ActionMailer::Base
  include Email::BuildEmailHelper

  def incompatible_plugin_support(args)
    build_email(
      args[:contact_emails],
      body: args[:raw],
      subject: args[:title],
      from: SiteSetting.notification_email,
    )
  end
end

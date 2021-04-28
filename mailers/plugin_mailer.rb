class PluginMailer < ::ActionMailer::Base
  include Email::BuildEmailHelper

  def incompatible_plugin_support(plugin, site, contact_emails, title, raw)
    build_email(
      contact_emails,
      body: raw,
      subject: title,
      from: SiteSetting.notification_email,
    )
  end
end

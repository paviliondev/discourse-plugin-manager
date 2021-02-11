class PluginMailer < ::ActionMailer::Base
  include Email::BuildEmailHelper

  def incompatible_plugin_site(plugin, site, contact_emails)
    if contact_emails.nil?
      build_email(
        SiteSetting.contact_email,
        body: "The plugin #{plugin} is incompatible on #{site}",
        subject: "Incompatible plugin on #{site}",
        from: SiteSetting.notification_email,
      )
    else
      build_email(
        SiteSetting.contact_email,
        body: "The plugin #{plugin} is incompatible on #{site}. The support contact for the plugin has also been contacted (#{contact_emails})",
        subject: "Incompatible plugin on #{site}",
        from: SiteSetting.notification_email,
      )
    end
  end

  def incompatible_plugin_support(plugin, site, contact_emails)
    byebug
    build_email(
      contact_emails,
      body: "The plugin #{plugin} you support is incompatible on #{site}, please take a look",
      subject: "Incompatible plugin on #{site}",
      from: SiteSetting.notification_email,
    )
  end
end
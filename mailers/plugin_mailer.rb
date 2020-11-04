class PluginMailer < ::ActionMailer::Base
  include Email::BuildEmailHelper

  def incompatible_plugin(plugin, site)
    build_email(
      SiteSetting.contact_email,
      body: "The plugin #{plugin} is incompatible on #{site}",
      subject: "Incompatible plugin on #{site}",
      from: SiteSetting.notification_email,
    )
  end
end
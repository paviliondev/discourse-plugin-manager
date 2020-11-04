module Jobs
  class SendPluginIncompatibleNotification < ::Jobs::Base
    def execute(args)
      [
        :plugin,
        :site
      ].each do |key|
        raise Discourse::InvalidParameters.new(key) unless args[key].present?
      end
      
      message = PluginMailer.incompatible_plugin(args[:plugin], args[:site])
      Email::Sender.new(message, :incompatible_plugin).send
    end
  end
end
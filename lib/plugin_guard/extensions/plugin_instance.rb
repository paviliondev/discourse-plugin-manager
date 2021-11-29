# frozen_string_literal: true
module ::PluginGuard::PluginInstanceExtension
  def notify_after_initialize
    color_schemes.each do |c|
      unless ColorScheme.where(name: c[:name]).exists?
        ColorScheme.create_from_base(name: c[:name], colors: c[:colors])
      end
    end

    initializers.each do |callback|
      begin
        callback.call(self)
      rescue => error
        PluginGuard::Error.handle(error)
        next
      end
    end
  end
end

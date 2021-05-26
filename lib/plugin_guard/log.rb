# frozen_string_literal: true

class ::PluginGuard::Log  
  attr_reader :type,
              :message,
              :discourse_sha,
              :discourse_branch,
              :plugin_sha,
              :plugin_branch,
              :date
  
  def initialize(plugin_guard, message, backtrace, type)
    return nil unless message
    
    @type = type || 'error'
    @message = message
    @backtrace = backtrace
    @discourse_sha = Discourse.git_version
    @discourse_branch = Discourse.git_branch
    @plugin_sha = plugin_guard.sha
    @plugin_branch = plugin_guard.branch
    @date = Time.now.iso8601
  end
end
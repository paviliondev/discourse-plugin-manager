# frozen_string_literal: true

class ::PluginManager::StatusHandler
  attr_reader :plugin

  def initialize(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
  end

  def perform(old_status, new_status)
    notifier = ::PluginManager::Notifier.new(@plugin.name)
    manifest = PluginManager::Manifest

    broken = !manifest.not_working?(old_status) && manifest.not_working?(new_status)
    fixed = manifest.not_working?(old_status) && !manifest.not_working?(new_status)

    if broken
      log_key = log_key(new_status)

      if log_key
        notifier.perform(:broken, log_key)
      end
    end

    if fixed
      log_key = log_key(old_status)

      if log_key
        resolve_log(log_key)
        notifier.perform(:fixed, log_key)
      end
    end
  end

  def resolve_log(key)
    log = ::PluginGuard::Log.get(key)
    log.resolved_at = Time.now.iso8601
    log.save
  end

  def log_key(status)
    PluginGuard::Log.key(@plugin.name.dasherize, status, @plugin.sha, PluginManager::Discourse.new.sha)
  end
end

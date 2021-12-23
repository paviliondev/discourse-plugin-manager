# frozen_string_literal: true

class ::PluginManager::StatusHandler
  attr_reader :plugin_name

  def initialize(plugin_name)
    @plugin_name = plugin_name
  end

  def perform(old_status, new_status)
    broken = broken?(old_status, new_status)
    fixed = fixed?(old_status, new_status)

    if broken || fixed
      plugin_sha = ::PluginManager::Plugin.get_sha(plugin_name)
      discourse_sha = ::PluginManager::Discourse.get_sha
      log_status = broken ? new_status : old_status
      log_key = ::PluginManager::Log.key(plugin_name, log_status, plugin_sha, discourse_sha)
      return false unless log_key

      log = ::PluginManager::Log.get(log_key)
      if !log
        ## should not be necessary, but must ensure we always have a log
        message_key = broken ? 'broken' : 'fixed'
        message = I18n.t("plugin_manager.notifier.#{message_key}.title", plugin_name: plugin_name)
        log = ::PluginManager::Log.add(
          plugin_name: plugin_name,
          status: new_status,
          message: message
        )
      end
      notifier = ::PluginManager::Notifier.new(plugin_name)

      if broken
        notifier.send(:broken, log)
      else
        log.resolved_at = Time.now.iso8601
        log.save
        notifier.send(:fixed, log)
      end
    end
  end

  def broken?(old_status, new_status)
    !PluginManager::Manifest.not_working?(old_status) && PluginManager::Manifest.not_working?(new_status)
  end

  def fixed?(old_status, new_status)
    PluginManager::Manifest.not_working?(old_status) && !PluginManager::Manifest.not_working?(new_status)
  end
end

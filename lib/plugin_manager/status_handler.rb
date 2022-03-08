# frozen_string_literal: true

class ::PluginManager::StatusHandler
  attr_reader :name,
              :git

  def initialize(name, git)
    @name = name
    @git = git
  end

  def perform(old_status, new_status, log_attrs = {})
    broken = broken?(old_status, new_status)
    fixed = fixed?(old_status, new_status)

    if broken || fixed
      status = broken ? new_status : old_status
      log = ::PluginManager::Log.get_unresolved(name, git)

      if !log
        attrs = {
          status: new_status
        }

        if log_attrs[:message]
          attrs[:message] = log_attrs[:message]
        else
          message_key = broken ? 'broken' : 'fixed'
          message = I18n.t("plugin_manager.notifier.#{message_key}.title", plugin_name: name)
        end

        if log_attrs[:message]
          attrs[:backtrace] = log_attrs[:backtrace]
        end

        log = ::PluginManager::Log.add(name, git, attrs)
      end

      notifier = ::PluginManager::Notifier.new(name)

      if broken
        notifier.send(:broken, log)
      else
        log.resolved_at = Time.now.iso8601
        log.save

        notifier.send(:fixed, log)
      end
    end

    MessageBus.publish("/#{PluginManager::NAMESPACE}/status-updated", name)

    true
  end

  def broken?(old_status, new_status)
    !PluginManager::Plugin::Status.not_working?(old_status) && PluginManager::Plugin::Status.not_working?(new_status)
  end

  def fixed?(old_status, new_status)
    PluginManager::Plugin::Status.not_working?(old_status) && !PluginManager::Plugin::Status.not_working?(new_status)
  end
end

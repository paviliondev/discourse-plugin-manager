# frozen_string_literal: true

class ::PluginManager::StatusHandler
  attr_reader :name,
              :branch,
              :discourse_branch

  def initialize(name, branch, discourse_branch)
    @name = name
    @branch = branch
    @discourse_branch = discourse_branch
  end

  def perform(old_status, new_status)
    broken = broken?(old_status, new_status)
    fixed = fixed?(old_status, new_status)

    if broken || fixed
      status = broken ? new_status : old_status
      log_key = ::PluginManager::Log.key(name, status, branch, discourse_branch)
      return false unless log_key

      log = ::PluginManager::Log.get(log_key)
      if !log
        message_key = broken ? 'broken' : 'fixed'
        message = I18n.t("plugin_manager.notifier.#{message_key}.title", plugin_name: name)
        log = ::PluginManager::Log.add(
          name: name,
          branch: branch,
          discourse_branch: discourse_branch,
          status: new_status,
          message: message
        )
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
  end

  def broken?(old_status, new_status)
    !PluginManager::Plugin::Status.not_working?(old_status) && PluginManager::Plugin::Status.not_working?(new_status)
  end

  def fixed?(old_status, new_status)
    PluginManager::Plugin::Status.not_working?(old_status) && !PluginManager::Plugin::Status.not_working?(new_status)
  end
end

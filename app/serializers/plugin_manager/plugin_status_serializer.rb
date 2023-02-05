# frozen_string_literal: true
class PluginManager::PluginStatusSerializer < ::ApplicationSerializer
  attributes :name,
             :branch,
             :sha,
             :discourse_branch,
             :discourse_sha,
             :status,
             :status_changed_at,
             :last_status_at,
             :test_status

  def status
    ::PluginManager::Plugin::Status.statuses.keys[object.status].to_s
  end

  def status_changed_at
    object.status_changed_at.to_time.strftime('%F %T')
  end

  def last_status_at
    object.last_status_at.to_time.strftime('%F %T')
  end

  def test_status
    ::PluginManager::TestManager.status.keys[object.test_status].to_s
  end

  def include_test_status?
    object.test_status.present?
  end
end

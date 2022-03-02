# frozen_string_literal: true
class PluginManager::PluginStatusSerializer < ::ApplicationSerializer
  attributes :name,
             :branch,
             :discourse_branch,
             :status,
             :status_changed_at,
             :test_status

  def status
    ::PluginManager::Plugin::Status.statuses.keys[object.status].to_s
  end

  def test_status
    ::PluginManager::TestManager.status.keys[object.test_status].to_s
  end

  def include_test_status?
    object.test_status.present?
  end
end

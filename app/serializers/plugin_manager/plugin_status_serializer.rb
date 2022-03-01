# frozen_string_literal: true
class PluginManager::PluginStatusSerializer < ::ApplicationSerializer
  attributes :name,
             :branch,
             :discourse_branch,
             :status,
             :status_changed_at,
             :test_status
end

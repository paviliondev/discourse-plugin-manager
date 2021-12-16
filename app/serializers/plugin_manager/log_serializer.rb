# frozen_string_literal: true
class PluginManager::LogSerializer < ::ApplicationSerializer
  attributes :status,
             :message,
             :backtrace,
             :issue_url,
             :test_url,
             :created_at,
             :updated_at
end

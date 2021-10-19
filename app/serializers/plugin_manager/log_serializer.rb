class PluginManager::LogSerializer < ::ApplicationSerializer
  attributes :type,
             :message,
             :backtrace,
             :issue_url,
             :test_url,
             :created_at,
             :updated_at
end
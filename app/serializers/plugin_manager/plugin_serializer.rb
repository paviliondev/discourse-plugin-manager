class PluginManager::PluginSerializer < ::ApplicationSerializer
  attributes :name,
             :url,
             :contact_emails,
             :installed_sha,
             :git_branch,
             :status,
             :test_status,
             :log

  def log
    log = ::PluginGuard::Log.list(object.name).first
    PluginManager::LogSerializer.new(log, root: false).as_json
  end
end

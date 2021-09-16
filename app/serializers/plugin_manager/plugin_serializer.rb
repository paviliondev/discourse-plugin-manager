class PluginManager::PluginSerializer < ::PluginManager::BasicPluginSerializer
  attributes :url,
             :contact_emails,
             :installed_sha,
             :git_branch,
             :test_status,
             :test_backend_coverage,
             :log

  def log
    log = ::PluginGuard::Log.list(object.name).first
    PluginManager::LogSerializer.new(log, root: false).as_json
  end

  def include_log?
    object.status === PluginManager::Manifest.status[:incompatible] ||
    object.status === PluginManager::Manifest.status[:tests_failing]
  end
end

class PluginManager::BasicPluginSerializer < ::ApplicationSerializer
  attributes :name,
             :status

  def status
    PluginManager::Manifest.status.key(object.status).to_s
  end
end

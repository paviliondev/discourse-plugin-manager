class PluginManager::OwnerSerializer < ::ApplicationSerializer
  attributes :name,
             :url,
             :email,
             :website,
             :avatar_url,
             :description,
             :type

  def type
    ::PluginManager::RepositoryOwner.types.key(object.type)
  end
end
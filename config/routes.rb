::PluginManager::Engine.routes.draw do
  get 'status' => 'status#show'
  get 'manifest' => 'manifest#index'
end

::Discourse::Application.routes.append do
  mount ::PluginManager::Engine, at: 'plugin-manager'
end
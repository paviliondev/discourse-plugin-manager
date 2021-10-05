# frozen_string_literal: true
PluginManager::Engine.routes.draw do
  get 'status' => 'status#index'
  get 'status/:plugin_name' => 'status#show'
end

Discourse::Application.routes.prepend do
  mount PluginManager::Engine, at: PluginManager::NAMESPACE
end
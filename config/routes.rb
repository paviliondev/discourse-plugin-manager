# frozen_string_literal: true
PluginManager::Engine.routes.draw do
  get 'status' => 'status#index'
  get 'status/:plugin_name' => 'status#show'
end

Discourse::Application.routes.prepend do
  mount PluginManager::Engine, at: PluginManager::NAMESPACE

  scope module: 'plugin_manager', constraints: AdminConstraint.new do
    get 'admin/plugin-manager' => 'plugin#index'
    get 'admin/plugin-manager/plugin' => 'plugin#index'
    put 'admin/plugin-manager/plugin/:plugin_name' => 'plugin#update'
    delete 'admin/plugin-manager/plugin/:plugin_name' => 'plugin#delete'
  end
end
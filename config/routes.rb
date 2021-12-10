# frozen_string_literal: true

class PluginManager::Engine < ::Rails::Engine
  engine_name PluginManager::NAMESPACE
  isolate_namespace PluginManager
end

PluginManager::Engine.routes.draw do
  get 'status' => 'status#index'
  get 'status/:plugin_name' => 'status#show'
  get 'plugin' => 'plugin#index'
  get 'plugin/retrieve' => 'plugin#retrieve'
  put 'plugin/:plugin_name' => 'plugin#save', constraints: AdminConstraint.new
  delete 'plugin/:plugin_name' => 'plugin#delete', constraints: AdminConstraint.new
end

Discourse::Application.routes.prepend do
  mount PluginManager::Engine, at: PluginManager::NAMESPACE

  scope module: 'plugin_manager', constraints: AdminConstraint.new do
    get 'admin/plugin-manager' => 'plugin#index'
  end
end

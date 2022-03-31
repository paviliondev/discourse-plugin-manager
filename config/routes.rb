# frozen_string_literal: true

class PluginManager::Engine < ::Rails::Engine
  engine_name PluginManager::NAMESPACE
  isolate_namespace PluginManager
end

PluginManager::Engine.routes.draw do
  get 'status' => 'plugin_status#index'
  get 'status/validate-key' => 'plugin_status#validate_key', constraints: { format: 'json' }
  get 'status/:plugin_name' => 'plugin_status#show'
  post 'status' => 'plugin_status#update', constraints: { format: 'json' }
  get 'discourse' => 'discourse#index'
  get 'plugin' => 'plugin#index'
  get 'plugin/category/:category_id' => 'plugin#category'
  get 'plugin/retrieve' => 'plugin#retrieve'
  get 'plugin/:plugin_name' => 'plugin#show'
  put 'plugin/:plugin_name' => 'plugin#save', constraints: AdminConstraint.new
  delete 'plugin/:plugin_name' => 'plugin#delete', constraints: AdminConstraint.new
  post 'user/register' => 'plugin_user#register', constraints: { format: 'json' }
end

Discourse::Application.routes.prepend do
  mount PluginManager::Engine, at: PluginManager::NAMESPACE

  scope module: 'plugin_manager', constraints: AdminConstraint.new do
    get 'admin/plugin-manager' => 'plugin#index'
  end

  %w{users u}.each do |root_path|
    get "#{root_path}/:username/plugins" => "plugin_manager/plugin_user#index"
    get "#{root_path}/:username/plugins/registered" => "plugin_manager/plugin_user#registered"
  end
end

# frozen_string_literal: true
class PluginManager::PluginUserSerializer < ::ApplicationSerializer
  attributes :name,
             :domain,
             :updated_at

  def updated_at
    registered_plugins_updated_at[object.domain]
  end

  protected

  def registered_plugins_updated_at
    @registered_plugins_updated_at ||= scope.user.registered_plugins_updated_at
  end
end

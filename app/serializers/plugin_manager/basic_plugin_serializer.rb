# frozen_string_literal: true
class PluginManager::BasicPluginSerializer < ::ApplicationSerializer
  attributes :name,
             :status,
             :status_changed_at

  def status
    PluginManager::Manifest.status.key(object.status).to_s
  end
end

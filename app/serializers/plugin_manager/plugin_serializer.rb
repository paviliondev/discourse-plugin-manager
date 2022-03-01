# frozen_string_literal: true
class PluginManager::PluginSerializer < ::ApplicationSerializer
  attributes :display_name,
             :url,
             :authors,
             :about,
             :owner,
             :contact_emails,
             :branch_url,
             :log,
             :owner,
             :status,
             :category_id

  def log
    log = ::PluginManager::Log.list(object.name).first
    PluginManager::LogSerializer.new(log, root: false).as_json
  end

  def include_log?
    object.status.present? && (
      object.status.status === PluginManager::Plugin::Status.statuses[:incompatible] ||
      object.status.status === PluginManager::Plugin::Status.statuses[:tests_failing]
    )
  end

  def status
    ::PluginManager::Plugin::Status.statuses.keys(object.status.status)
  end

  def include_status?
    object.status.present?
  end

  def owner
    PluginManager::OwnerSerializer.new(object.owner, root: false).as_json
  end

  def include_owner?
    object.owner.present?
  end
end

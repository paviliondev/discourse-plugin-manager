# frozen_string_literal: true
class PluginManager::PluginSerializer < ::ApplicationSerializer
  attributes :name,
             :display_name,
             :url,
             :authors,
             :about,
             :owner,
             :contact_emails,
             :maintainers,
             :maintainer_user,
             :branch_url,
             :log,
             :owner,
             :test_host,
             :status,
             :category_id,
             :tags

  def log
    log = ::PluginManager::Log.list(object.name).first
    PluginManager::LogSerializer.new(log, root: false).as_json
  end

  def include_log?
    object.status.present? &&
      PluginManager::Plugin::Status.not_working?(object.status.status)
  end

  def status
    PluginManager::PluginStatusSerializer.new(object.status, root: false).as_json
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

  def maintainer_user
    if user = User.find_by(username: object.maintainer)
      BasicUserSerializer.new(user, root: false).as_json
    end
  end

  def include_maintainer_user?
    options[:include_maintainer_user] && object.maintainer.present?
  end
end

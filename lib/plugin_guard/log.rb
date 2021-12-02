# frozen_string_literal: true

class ::PluginGuard::Log
  include ActiveModel::Serialization

  attr_reader :type,
              :message,
              :backtrace,
              :discourse_sha,
              :discourse_branch,
              :plugin_name,
              :plugin_sha,
              :plugin_branch,
              :test_url

  attr_accessor :created_at,
                :updated_at,
                :issue_url

  def initialize(attrs)
    attrs = attrs.with_indifferent_access
    @type = attrs[:type]
    @message = attrs[:message]
    @backtrace = attrs[:backtrace]
    @discourse_sha = attrs[:discourse_sha]
    @discourse_branch = attrs[:discourse_branch]
    @plugin_name = attrs[:plugin_name]
    @plugin_sha = attrs[:plugin_sha]
    @plugin_branch = attrs[:plugin_branch]
    @test_url = attrs[:test_url]
    @issue_url = attrs[:issue_url]
    @created_at = attrs[:created_at]
    @updated_at = attrs[:updated_at]
  end

  def save
    @updated_at = Time.now.iso8601
    ::PluginManagerStore.set(PluginGuard::NAMESPACE, key, self.instance_values)
  end

  def digest
    Digest::SHA256.hexdigest("#{type.dasherize}-#{plugin_sha}-#{discourse_sha}-#{message}")
  end

  def key
    "#{plugin_name}-log-#{digest}"
  end

  def self.add(plugin_name: nil, plugin_sha: nil, plugin_branch: nil, message: nil, backtrace: nil, test_url: nil, issue_url: nil, type: nil)
    plugin = ::PluginManager::Plugin.get_or_create(plugin_name)
    attrs = {
      plugin_name: plugin_name,
      plugin_sha: plugin_sha || (plugin && plugin.installed_sha || ""),
      plugin_branch: plugin_branch || (plugin && plugin.git_branch || ""),
      discourse_sha: Discourse.git_version,
      discourse_branch: Discourse.git_branch,
      message: message,
      type: type
    }

    log = get(new(attrs).key)

    if log
      log.backtrace = backtrace if backtrace.present?
      log.test_url = test_url if issue_url.present?
      log.issue_url = issue_url if test_url.present?
    else
      attrs[:backtrace] = backtrace if backtrace.present?
      attrs[:issue_url] = issue_url if issue_url.present?
      attrs[:test_url] = test_url if test_url.present?

      log = new(attrs)
      log.created_at = Time.now.iso8601
    end

    log.save
  end

  def self.get(key)
    raw = ::PluginManagerStore.get(PluginGuard::NAMESPACE, key)
    raw ? new(raw) : nil
  end

  def self.list(plugin_name = nil)
    query = PluginStoreRow.where(plugin_name: PluginGuard::NAMESPACE)
    query = query.where("key LIKE '#{plugin_name}-log-%'") if plugin_name
    query.order("value::json->>'updated_at' DESC")
      .map { |record| new(JSON.parse(record.value)) }
  end
end

# frozen_string_literal: true

class ::PluginManager::Log
  include ActiveModel::Serialization

  attr_reader :status,
              :message,
              :discourse_sha,
              :discourse_branch,
              :plugin_name,
              :plugin_sha,
              :plugin_branch

  attr_accessor :backtrace,
                :created_at,
                :updated_at,
                :resolved_at,
                :issue_url,
                :test_url,
                :issue_id

  def initialize(attrs)
    attrs = attrs.with_indifferent_access
    @status = attrs[:status]
    @message = attrs[:message]
    @backtrace = attrs[:backtrace]
    @discourse_sha = attrs[:discourse_sha]
    @discourse_branch = attrs[:discourse_branch]
    @plugin_name = attrs[:plugin_name]
    @plugin_sha = attrs[:plugin_sha]
    @plugin_branch = attrs[:plugin_branch]
    @test_url = attrs[:test_url]
    @issue_url = attrs[:issue_url]
    @issue_id = attrs[:issue_id]
    @created_at = attrs[:created_at]
    @updated_at = attrs[:updated_at]
    @resolved_at = attrs[:resolved_at]
  end

  def save
    @updated_at = Time.now.iso8601
    ::PluginManagerStore.set(
      self.class.plugin_name,
      self.class.key(plugin_name, status, plugin_sha, discourse_sha),
      self.instance_values
    )
  end

  def key
    self.class.key(plugin_name, status, plugin_sha, discourse_sha)
  end

  def self.add(plugin_name: nil, status: nil, message: nil, backtrace: nil, test_url: nil)
    plugin_sha = PluginManager::Plugin.get_sha(plugin_name)
    plugin_branch = PluginManager::Plugin.get_branch(plugin_name)
    return if !plugin_sha || !plugin_branch

    discourse_sha = PluginManager::Discourse.get_sha
    discourse_branch = PluginManager::Discourse.get_branch
    attrs = {
      plugin_name: plugin_name,
      plugin_sha: plugin_sha,
      plugin_branch: plugin_branch,
      discourse_sha: discourse_sha,
      discourse_branch: discourse_branch,
      message: message,
      status: status
    }
    log_key = key(plugin_name, status, plugin_sha, discourse_sha)
    log = get(log_key)

    if log
      log.backtrace = backtrace if backtrace.present?
      log.test_url = test_url if test_url.present?
    else
      attrs[:backtrace] = backtrace if backtrace.present?
      attrs[:test_url] = test_url if test_url.present?

      log = new(attrs)
      log.created_at = Time.now.iso8601
    end

    log.save ? log : nil
  end

  def self.get(key)
    raw = ::PluginManagerStore.get(plugin_name, key)
    raw ? new(raw) : nil
  end

  def self.list(plugin_name = nil)
    query = PluginStoreRow.where(plugin_name: plugin_name)
    query = query.where("key LIKE '#{plugin_name}-log-%'") if plugin_name
    query.order("value::json->>'updated_at' DESC")
      .map { |record| new(JSON.parse(record.value)) }
  end

  def self.digest(status, plugin_sha, discourse_sha)
    Digest::SHA256.hexdigest("#{status}-#{plugin_sha}-#{discourse_sha}")
  end

  def self.key(plugin_name, status, plugin_sha, discourse_sha)
    "#{plugin_name.dasherize}-#{digest(status, plugin_sha, discourse_sha)}"
  end

  def self.plugin_name
    PluginManager::NAMESPACE + "-log"
  end
end

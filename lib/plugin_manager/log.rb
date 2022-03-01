# frozen_string_literal: true

class ::PluginManager::Log
  include ActiveModel::Serialization

  attr_reader :name,
              :branch,
              :discourse_branch,
              :status,
              :message

  attr_accessor :backtrace,
                :created_at,
                :updated_at,
                :resolved_at,
                :issue_url,
                :test_url,
                :issue_id

  def initialize(attrs)
    attrs = attrs.with_indifferent_access
    @name = attrs[:name]
    @branch = attrs[:branch]
    @discourse_branch = attrs[:discourse_branch]

    @status = attrs[:status]
    @message = attrs[:message]
    @backtrace = attrs[:backtrace]
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
      self.class.db_key,
      self.class.key(name, status, branch, discourse_branch),
      self.instance_values
    )
  end

  def key
    self.class.key(name, status, branch, discourse_branch)
  end

  def self.add(name: nil, branch: nil, discourse_branch: nil, status: nil, message: nil, backtrace: nil, test_url: nil)
    return if !branch || !discourse_branch
    attrs = {
      name: name,
      branch: branch,
      discourse_branch: discourse_branch,
      message: message,
      status: status
    }
    log_key = key(name, status, branch, discourse_branch)
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
    raw = ::PluginManagerStore.get(db_key, key)
    raw ? new(raw) : nil
  end

  def self.list(plugin_name = nil)
    query = PluginStoreRow.where(plugin_name: db_key)
    query = query.where("key LIKE '#{plugin_name}-log-%'") if plugin_name
    query.order("value::json->>'updated_at' DESC")
      .map { |record| new(JSON.parse(record.value)) }
  end

  def self.digest(status, plugin_sha, discourse_sha)
    Digest::SHA256.hexdigest("#{status}-#{plugin_sha}-#{discourse_sha}")
  end

  def self.key(name, status, branch, discourse_branch)
    "#{name.dasherize}-#{digest(status, branch, discourse_branch)}"
  end

  def self.db_key
    PluginManager::NAMESPACE + "-log"
  end
end

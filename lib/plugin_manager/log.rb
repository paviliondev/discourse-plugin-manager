# frozen_string_literal: true

class ::PluginManager::Log
  include ActiveModel::Serialization

  attr_reader :key,
              :plugin_name,
              :branch,
              :sha,
              :discourse_branch,
              :discourse_sha,
              :status,
              :message

  attr_accessor :backtrace,
                :created_at,
                :updated_at,
                :resolved_at,
                :issue_id,
                :issue_url,
                :test_url,
                :issue_id

  def initialize(key, attrs)
    attrs = attrs.with_indifferent_access

    @key = key || self.class.key(attrs[:plugin_name])
    @plugin_name = attrs[:plugin_name]
    @branch = attrs[:branch]
    @sha = attrs[:sha]
    @discourse_branch = attrs[:discourse_branch]
    @discourse_sha = attrs[:discourse_sha]

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
    ::PluginManagerStore.set(self.class.db_key, key, self.instance_values)
  end

  def self.add(plugin_name, git = {}, attrs = {})
    log = get_unresolved(plugin_name, git)

    if log
      log.backtrace = attrs[:backtrace] if attrs[:backtrace].present?
      log.test_url = attrs[:test_url] if attrs[:test_url].present?
    else
      new_attrs = {}
      new_attrs[:plugin_name] = plugin_name
      new_attrs.merge!(git)
      new_attrs.merge!(attrs)

      log = new(nil, new_attrs)
      log.created_at = Time.now.iso8601
    end

    log.save ? log : nil
  end

  def self.get_unresolved(plugin_name, git = {})
    record = list_query(plugin_name)
      .where("value::json->>'branch' = '#{git[:branch]}' AND value::json->>'discourse_branch' = '#{git[:discourse_branch]}'")
      .where("coalesce((value::json->>'resolved_at'), '') = ''")
      .order("value::json->>'updated_at' DESC")
      .first
    record ? new(record.key, JSON.parse(record.value)) : nil
  end

  def self.list_query(plugin_name = nil)
    query = PluginStoreRow.where(plugin_name: db_key)

    if plugin_name
      query.where("key LIKE '#{plugin_name}-%'")
    else
      query
    end
  end

  def self.list(plugin_name = nil)
    list_query(plugin_name)
      .order("value::json->>'updated_at' DESC")
      .map { |record| new(JSON.parse(record.value)) }
  end

  def self.key(plugin_name)
    "#{plugin_name.dasherize}-#{SecureRandom.hex(16)}"
  end

  def self.db_key
    PluginManager::NAMESPACE + "-log"
  end
end

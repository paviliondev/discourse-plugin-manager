# frozen_string_literal: true

class ::PluginGuard::Log
  include ActiveModel::Serialization

  attr_reader :key,
              :type,
              :message,
              :backtrace,
              :discourse_sha,
              :discourse_branch,
              :plugin_name,
              :plugin_sha,
              :plugin_branch,
              :test_url,
              :issue_url,
              :date

  def initialize(attrs, key: nil)
    attrs = attrs.with_indifferent_access
    @key = key if key.present?
    @type = attrs[:type]
    @message = attrs[:message]
    @backtrace = attrs[:backtrace]
    @discourse_sha = Discourse.git_version
    @discourse_branch = Discourse.git_branch
    @plugin_name = attrs[:plugin_name]
    @plugin_sha = attrs[:plugin_sha]
    @plugin_branch = attrs[:plugin_branch]
    @test_url = attrs[:test_url]
    @issue_url = attrs[:issue_url]
    @date = Time.now.iso8601
  end

  def save
    key = "#{self.class.key(plugin_name)}-#{SecureRandom.hex(12)}" unless key.present?
    PluginStore.set(PluginGuard::NAMESPACE, key, self.instance_values)
  end

  def self.add(plugin_name: nil, plugin_sha: nil, plugin_branch: nil, message: nil, backtrace: nil, test_url: nil, issue_url: nil, type: nil)
    byebug
    plugin = ::PluginManager::Plugin.get_or_create(plugin_name)
    attrs = {
      plugin_name: plugin_name,
      plugin_sha: plugin_sha || (plugin && plugin.installed_sha || ""),
      plugin_branch: plugin_branch || (plugin && plugin.git_branch || ""),
      message: message,
      type: type
    }

    attrs[:backtrace] = backtrace if backtrace.present?
    attrs[:issue_url] = issue_url if issue_url.present?
    attrs[:test_url] = test_url if test_url.present?

    log = PluginGuard::Log.new(attrs)
    log.save
  end

  def self.key(plugin_name)
    "#{plugin_name}-log"
  end

  def self.list(plugin_name)
    PluginStoreRow.where("
      plugin_name = '#{PluginGuard::NAMESPACE}' AND
      key LIKE '#{key(plugin_name)}-%'
    ").order("value::json->>'date' DESC")
      .map do |record|
        new(JSON.parse(record.value), key: record.key)
      end
  end
end
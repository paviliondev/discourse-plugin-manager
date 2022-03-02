# frozen_string_literal: true

class ::PluginManager::Plugin::Status
  include ActiveModel::Serialization

  PAGE_LIMIT = 30
  KEY_DELIMITER = "|"

  attr_reader :name,
              :branch,
              :discourse_branch,
              :key

  attr_accessor :status,
                :status_changed_at,
                :test_status

  def initialize(name, attrs)
    @name = name
    @branch = attrs[:branch]
    @discourse_branch = attrs[:discourse_branch]
    @key = self.class.status_key(@name, @branch, @discourse_branch)

    # changable attrs
    @status = attrs[:status].to_i
    @status_changed_at = attrs[:status_changed_at]
    @test_status = attrs[:test_status].present? ? attrs[:test_status].to_i : nil
  end

  def self.statuses
    @statuses ||= Enum.new(
      unknown: 0,
      compatible: 1,
      incompatible: 2,
      tests_failing: 3,
      recommended: 4
    )
  end

  def self.update(name, branch, discourse_branch, attrs)
    old_status = get(name, branch, discourse_branch)

    new_attrs = {}
    [:status, :test_status].each do |attr|
      new_attrs[attr] = attrs[attr] || old_status.send(attr)
    end

    return false if new_attrs.values.blank?

    new_attrs[:status] = normalize_status(**new_attrs)
    status_changed = old_status.status != new_attrs[:status]
    new_attrs[:status_changed_at] = status_changed ? Time.now : old_status.status_changed_at

    key = status_key(name, branch, discourse_branch)
    new_attrs[:name] = name
    new_attrs[:branch] = branch
    new_attrs[:discourse_branch] = discourse_branch

    ::PluginManagerStore.set(db_key, key, new_attrs)

    if status_changed
      status_handler = ::PluginManager::StatusHandler.new(name, branch, discourse_branch)
      status_handler.perform(old_status.status, new_attrs[:status])
    end
  end

  def self.normalize_status(status:, test_status:)
    if incompatible?(status)
      statuses[:incompatible]
    elsif PluginManager::TestManager.failing?(test_status)
      statuses[:tests_failing]
    elsif PluginManager::TestManager.passing?(test_status)
      statuses[:recommended]
    elsif compatible?(status)
      statuses[:compatible]
    else
      statuses[:unknown]
    end
  end

  def self.get(name, branch, discourse_branch)
    raw = (::PluginManagerStore.get(db_key, status_key(name, branch, discourse_branch)) || {}).symbolize_keys
    new(name, raw)
  end

  def self.list(keys: [], discourse_branch: nil, page: nil)
    query = ::PluginStoreRow.where("plugin_name = '#{db_key}'")

    if keys.any?
      query = query.where(key: keys)
    end

    if discourse_branch.present?
      query = query.where("split_part(key, '#{KEY_DELIMITER}', 3) = ?", discourse_branch)
    end

    total = query.size

    if page
      query = query.limit(PAGE_LIMIT).offset(page * PAGE_LIMIT)
    end

    statuses = query.map do |record|
      begin
        attrs = JSON.parse(record.value)
      rescue JSON::ParserError
        attrs = {}
      end
      new(attrs['name'], attrs.with_indifferent_access)
    end

    OpenStruct.new(statuses: statuses, total: total)
  end

  def self.db_key
    ::PluginManager::NAMESPACE + "-status"
  end

  def self.status_key(name, branch, discourse_branch)
    "#{name.dasherize}#{KEY_DELIMITER}#{branch}#{KEY_DELIMITER}#{discourse_branch}"
  end

  def self.working?(status)
    compatible?(status) || recommended?(status)
  end

  def self.not_working?(status)
    incompatible?(status) || tests_failing?(status)
  end

  def self.compatible?(status)
    status == statuses[:compatible]
  end

  def self.incompatible?(status)
    status == statuses[:incompatible]
  end

  def self.tests_failing?(status)
    status == statuses[:tests_failing]
  end

  def self.recommended?(status)
    status == statuses[:recommended]
  end

  def self.build_unknown_status(plugin, discourse_branch)
    new(
      plugin.name,
      branch: plugin.default_branch,
      discourse_branch: discourse_branch,
      status: statuses[:unknown],
      status_changed_at: nil,
    )
  end
end

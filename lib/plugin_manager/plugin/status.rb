# frozen_string_literal: true

class ::PluginManager::Plugin::Status
  include ActiveModel::Serialization

  DISCOURSE_URL = "https://github.com/discourse/discourse"

  PAGE_LIMIT = 30
  KEY_DELIMITER = "|"

  attr_reader :name,
              :branch,
              :sha,
              :discourse_branch,
              :discourse_sha,
              :key

  attr_accessor :status,
                :status_changed_at,
                :test_status

  def initialize(name, attrs)
    @name = name
    @branch = attrs[:branch]
    @sha = attrs[:sha]
    @discourse_branch = attrs[:discourse_branch]
    @discourse_sha = attrs[:discourse_sha]
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

  def self.required_git_attrs
    [:branch, :sha, :discourse_branch, :discourse_sha]
  end

  def self.has_required_git_attrs?(git)
    required_git_attrs.all? { |attr| git[attr].present? }
  end

  def self.update(name, git = {}, attrs = {})
    result = OpenStruct.new(success: false, errors: [])
    current_status = get(name, git[:branch], git[:discourse_branch])

    if attrs[:status].present? && attrs[:test_status].nil?
      if !has_required_git_attrs?(git)
        result.errors << "Does not have required git attributes"
        return result
      end

      if current_status.present? && !attrs[:skip_git_check]
        discourse_equal = current_status.discourse_sha === git[:discourse_sha]
        plugin_equal = current_status.sha === git[:sha]

        if discourse_equal && plugin_equal
          result.errors << "Same Discourse commit and plugin commit as current status."
          return result
        end

        since = current_status.status_changed_at
        if !discourse_equal && !commit_since?(DISCOURSE_URL, current_status.discourse_branch, git[:discourse_sha], since)
          result.errors << "Discourse commit is older than current status."
          return result
        end

        plugin = PluginManager::Plugin.get(current_status.name)
        if !commit_since?(plugin.url, current_status.branch, git[:sha], since)
          result.errors << "Plugin commit is the same or older than current status."
          return result
        end
      end
    end

    new_attrs = {}
    [:status, :test_status].each do |attr|
      new_attrs[attr] = attrs[attr] || (current_status && current_status.send(attr))
    end
    if new_attrs.values.blank?
      result.errors << "No valid status attributes"
      return result
    end

    new_attrs[:status] = normalize_status(**new_attrs)
    status_changed = current_status && (current_status.status != new_attrs[:status])
    new_attrs[:status_changed_at] = (!current_status || status_changed) ? Time.now : current_status.status_changed_at

    key = status_key(name, git[:branch], git[:discourse_branch])
    new_attrs[:name] = name
    required_git_attrs.each { |attr| new_attrs[attr] = git[attr] }

    ::PluginManagerStore.set(db_key, key, new_attrs)

    if status_changed
      status_handler = ::PluginManager::StatusHandler.new(name, git)
      result.success = status_handler.perform(
        current_status.status,
        new_attrs[:status],
        attrs.slice(:backtrace, :message)
      )
    else
      result.success = true
    end

    result
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
    raw.present? ? new(name, raw) : nil
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

  def self.placeholder_status(plugin, discourse_branch)
    new(
      plugin.name,
      branch: plugin.default_branch,
      discourse_branch: discourse_branch,
      status: statuses[:unknown],
      status_changed_at: nil,
    )
  end

  def self.commit_since?(url, branch, sha, since)
    manager = PluginManager::RepositoryManager.new(url, branch)
    commits_since = manager.get_commits(since: since)
    commits_since.any? { |c| c[:sha] === sha }
  end
end

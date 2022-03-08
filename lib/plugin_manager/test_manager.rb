# frozen_string_literal: true
class ::PluginManager::TestManager
  attr_reader :host,
              :domain,
              :branch,
              :discourse_branch

  def initialize(host_name, branch, discourse_branch)
    @host = PluginManager::TestHost.get(host_name)
    return unless @host

    @branch = branch
    @discourse_branch = discourse_branch
    @domain = host.domain
  end

  def self.status
    @status ||= ::Enum.new(
      passing: 0,
      failing: 1
    )
  end

  def ready?
    domain.present?
  end

  def update(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
    return nil unless @plugin && @plugin.url

    @host.plugin = @plugin
    @host.branch = branch
    @host.discourse_branch = discourse_branch

    test_status = request_test_status

    if !test_status.nil?
      attrs = {}
      attrs[:test_status] = test_status
      attrs[:branch] = branch
      attrs[:discourse_branch] = discourse_branch

      PluginManager::Plugin.set(@plugin.name, attrs)
    end
  end

  def self.passing?(test_status)
    test_status == PluginManager::TestManager.status[:passing]
  end

  def self.failing?(test_status)
    test_status == PluginManager::TestManager.status[:failing]
  end

  protected

  def request_test_status
    status_path = @host.status_path

    if status_path && response = request(status_path)
      @host.get_status_from_response(response)
    else
      nil
    end
  end

  def request(endpoint, opts = {})
    begin
      response = Excon.get("https://#{@host.domain}/#{endpoint}")
    rescue Excon::Error
      response = nil
    end

    if response && response.status == 200
      JSON.parse(response.body)
    else
      nil
    end
  end
end

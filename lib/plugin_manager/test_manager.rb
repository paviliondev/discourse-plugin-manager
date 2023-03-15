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
    @host.manager = self

    status_response = request(@host.status_path)
    test_status = @host.get_status_from_response(status_response)

    if !test_status.nil?
      attrs = {}
      attrs[:test_status] = test_status
      attrs[:branch] = branch
      attrs[:discourse_branch] = discourse_branch
      attrs[:message] = @host.test_error if @host.test_error

      PluginManager::Plugin.set(@plugin.name, attrs)
    end
  end

  def self.passing?(test_status)
    test_status == PluginManager::TestManager.status[:passing]
  end

  def self.failing?(test_status)
    test_status == PluginManager::TestManager.status[:failing]
  end

  def request(endpoint = nil, opts = {})
    url = opts[:url] || "https://#{@host.domain}/#{endpoint}"
    middlewares = Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower]
    connection = Excon.new(url, middlewares: middlewares)

    begin
      response = connection.request(opts)
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

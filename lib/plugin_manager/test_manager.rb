class ::PluginManager::TestManager
  COVERAGE_FILE ||= "coverage/.last_run.json"

  attr_reader :host,
              :domain

  attr_accessor :plugin

  def initialize(host_name)
    @host = PluginManager::TestHost.get(host_name)
    return unless @host
    @domain = host.domain
    @recommended_coverage_threshold = SiteSetting.plugin_manager_recommended_coverage_threshold
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
    @host.branch = @plugin.git_branch

    plugin_attrs = {}

    if test_backend_coverage.present? && plugin.test_backend_coverage != test_backend_coverage
      plugin_attrs[:test_backend_coverage] = test_backend_coverage
    end

    if test_status.present? && plugin.test_status != test_status
      plugin_attrs[:test_status] = test_status
    end

    if @plugin.status == PluginManager::Manifest.status[:compatible]
      if test_status == PluginManager::TestManager.status[:passing] && test_backend_coverage.to_i >= @recommended_coverage_threshold
        plugin_attrs[:status] = PluginManager::Manifest.status[:recommended]
      end

      if test_status == PluginManager::TestManager.status[:failing]
        plugin_attrs[:status] = PluginManager::Manifest.status[:tests_failing]
      end
    end

    if test_status == PluginManager::TestManager.status[:failing]
      PluginGuard::Log.add(
        type: 'test_error',
        plugin_name: @plugin.name,
        plugin_sha: @host.test_sha,
        plugin_branch: @host.test_branch,
        message: I18n.t("plugin_manager.test.error", test_name: @host.test_name),
        test_url: @host.test_url
      )
    end

    if plugin_attrs.present?
      ::PluginManager::Plugin.set(@plugin.name, plugin_attrs)
    end
  end

  def test_backend_coverage
    @test_backend_coverage ||= begin
      file_path = "#{Rails.root}/plugins/#{@plugin.name}/#{COVERAGE_FILE}"
      return nil if !File.exist?(file_path)
      coverage = JSON.parse(File.read(file_path))
      coverage["result"]["line"]
    end
  end

  def test_status
    @test_status ||= begin
      status_path = @host.get_status_path

      if status_path && response = request(status_path)
        @host.get_status_from_response(response)
      else
        nil
      end
    end
  end

  def request(endpoint, opts={})
    response = Excon.get("https://#{@host.domain}/#{endpoint}")

    if response.status == 200
      JSON.parse(response.body)
    else
      nil
    end
  end
end
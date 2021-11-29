class ::PluginManager::RepositoryManager
  COVERAGE_FILE ||= "coverage/.last_run.json"

  attr_reader :host,
              :domain

  attr_accessor :plugin

  def initialize(host_name)
    @host = PluginManager::RepositoryHost.get(host_name)
    return unless @host
    @domain = host.domain
  end

  def ready?
    domain.present?
  end

  def get_owner(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)

    return nil unless @plugin && @plugin.url
    @host.plugin = @plugin

    response = request(@host.get_owner_path)
    return nil unless response

    @host.get_owner_from_response(response)
  end

  protected

  def request(endpoint, opts={})
    response = Excon.get("https://#{@host.domain}/#{endpoint}")

    if response.status == 200
      JSON.parse(response.body)
    else
      nil
    end
  end
end

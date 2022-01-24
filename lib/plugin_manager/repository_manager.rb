# frozen_string_literal: true
class ::PluginManager::RepositoryManager
  COVERAGE_FILE ||= "coverage/.last_run.json"

  attr_reader :host,
              :domain

  def initialize(url, branch = nil)
    host_name = PluginManager::RepositoryHost.get_name(url)
    @host = PluginManager::RepositoryHost.get(host_name)

    if @host
      @host.url = url
      @host.branch = branch || get_default_branch
    end
  end

  def ready?
    @host && @host.domain.present? && @host.branch.present?
  end

  def get_default_branch
    response = request(@host.repository_path)
    response ? response["default_branch"] : nil
  end

  def get_owner
    response = request(@host.owner_path)
    response ? @host.get_owner_from_response(response) : nil
  end

  def get_plugin_data
    response = request(@host.plugin_file_path)
    return if !response

    OpenStruct.new(
      file: @host.get_file_from_response(response),
      sha: @host.get_sha_from_response(response)
    )
  end

  protected

  def request(endpoint, opts = {})
    response = Excon.get("https://#{@host.domain}/#{endpoint}")

    if response.status == 200
      JSON.parse(response.body)
    else
      nil
    end
  end
end

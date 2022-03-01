# frozen_string_literal: true
class ::PluginManager::RepositoryManager
  attr_reader :host,
              :domain

  def initialize(url, branch = nil)
    host_name = PluginManager::RepositoryHost.get_name(url)
    @host = PluginManager::RepositoryHost.get(host_name)

    if @host
      @host.url = url
      @host.branch = branch
    end
  end

  def ready?
    @host && @host.domain.present? && @host.branch.present?
  end

  def get_repository
    request(@host.repository_path)
  end

  def get_default_branch
    response = get_repository
    response ? response["default_branch"] : nil
  end

  def get_owner
    response = request(@host.owner_path)
    response ? @host.get_owner_from_response(response) : nil
  end

  def get_commits(after_sha:)
    response = request(@host.commits_path, { body: { after_sha: after_sha } })
    response ? @host.get_commits_from_response(response) : nil
  end

  def get_plugin_data
    response = request(@host.plugin_file_path)
    return if !response

    OpenStruct.new(
      file: @host.get_file_from_response(response)
    )
  end

  protected

  def request(endpoint, opts = {})
    url = "https://#{@host.domain}/#{endpoint}"

    headers = {}
    headers["User-Agent"] = "discourse-plugin-manager"
    headers["Content-Type"] = "application/json" if opts[:body]

    connection = Excon.new(
      url,
      headers: headers,
      middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::RedirectFollower]
    )

    params = { method: 'GET' }
    params[:body] = JSON.generate(opts[:body]) if opts[:body]

    response = connection.request(params)

    if response.status == 200
      JSON.parse(response.body)
    else
      nil
    end
  end
end

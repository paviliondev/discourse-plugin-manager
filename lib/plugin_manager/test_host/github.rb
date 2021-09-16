class PluginManager::TestHost::Github < PluginManager::TestHost  
  def initialize
    @name = 'github'
    @config = '.github/workflows/plugin-tests.yml'
    @domain = 'api.github.com'
    @branch = 'main'
  end

  def repo_path
    @repo_path ||= URI(@plugin.url).path
  end

  def get_status_path
    "repos#{repo_path}/actions/runs?branch=#{@branch}&status=completed&per_page=1&page=1"
  end

  def get_status_from_response(response)
    runs = response['workflow_runs']

    if runs.present?
      latest_run = runs.first

      @test_sha = latest_run['head_sha']
      @test_branch = latest_run['head_branch']
      @test_name = latest_run['name']
      @test_url = latest_run['html_url']

      if latest_run["conclusion"] === "success"
        return PluginManager::TestManager.status[:passing]
      end
    end

    PluginManager::TestManager.status[:failing]
  end
end
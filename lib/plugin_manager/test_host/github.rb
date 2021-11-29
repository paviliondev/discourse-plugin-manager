# frozen_string_literal: true
class PluginManager::TestHost::Github < PluginManager::TestHost
  def initialize
    @name = 'github'
    @config = '.github/workflows/plugin-tests.yml'
    @domain = "#{basic_auth? ? "#{client_id}:#{client_secret}@" : ""}api.github.com"
  end

  def repo_path
    @repo_path ||= URI(@plugin.url).path
  end

  def get_status_path
    "repos#{repo_path}/actions/runs?branch=#{@branch}&status=completed&per_page=1&page=1"
  end

  def get_status_from_response(response)
    runs = response['workflow_runs']
    return nil unless runs.present?
    latest_run = runs.first

    @test_sha = latest_run['head_sha']
    @test_branch = latest_run['head_branch']
    @test_name = latest_run['name']
    @test_url = latest_run['html_url']

    if latest_run["conclusion"] === "success"
      PluginManager::TestManager.status[:passing]
    else
      PluginManager::TestManager.status[:failing]
    end
  end

  def basic_auth?
    client_id.present? && client_secret.present?
  end

  def client_id
    SiteSetting.plugin_manager_github_oauth_client_id
  end

  def client_secret
    SiteSetting.plugin_manager_github_oauth_client_secret
  end
end

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

  def status_path
    "repos#{repo_path}/actions/runs?branch=#{@branch}&status=completed&per_page=5&page=1"
  end

  def config_path
    "repos#{repo_path}/contents/#{@config}"
  end

  def tests_workflow_name
    "Discourse Plugin"
  end

  def check_runs_path(check_suite_id)
    "repos#{repo_path}/check-suites/#{check_suite_id}/check-runs?status=completed"
  end

  def test_check_runs
    %w(frontend_tests backend_tests)
  end

  def test_check_run?(run)
    test_check_runs.any? { |tcr| run['name'].include?(tcr) }
  end

  def failed_run?(run)
    run['conclusion'] === "failure"
  end

  def run_error_message(run)
    message = I18n.t("plugin_manager.test.failed", test_name: run["name"])
    return message unless run["output"] && run["output"]["annotations_url"]

    annotations = @manager.request(nil, url: run["output"]["annotations_url"])
    message = annotations.map { |a| a['message'] }.join(', ')
    I18n.t("plugin_manager.test.failed_with_message", test_name: run["name"], message: message)
  end

  def build_test_error(runs)
    message = runs.map { |r| run_error_message(r) }.join(', ')
  end

  def get_status_from_response(response)
    latest_run = response['workflow_runs'].find { |r| r["name"] === tests_workflow_name }
    return nil unless latest_run.present?

    @test_sha = latest_run['head_sha']
    @test_branch = latest_run['head_branch']
    @test_name = latest_run['name']
    @test_url = latest_run['html_url']
    @check_suite_id = latest_run['check_suite_id']

    if latest_run["conclusion"] === "success"
      PluginManager::TestManager.status[:passing]
    else
      check_runs = @manager.request(check_runs_path(latest_run["check_suite_id"]))

      if check_runs && check_runs['check_runs']
        failing_test_runs = check_runs['check_runs'].select { |cr| test_check_run?(cr) && failed_run?(cr) }
        return PluginManager::TestManager.status[:passing] if failing_test_runs.blank?

        @test_error = build_test_error(failing_test_runs)
      end

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

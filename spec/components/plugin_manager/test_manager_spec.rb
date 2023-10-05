# frozen_string_literal: true
require_relative '../../plugin_helper'

# workflow indexes
# 0: "Discourse Plugin"

# text check indexes
# 0: "ci / linting"
# 1: "ci / check_for_tests"
# 2: "ci / frontend_tests"
# 3: "ci / backend_tests"

describe PluginManager::TestManager do
  let(:incompatible_plugin) { "incompatible_plugin" }
  let(:test_response_body) { File.read("#{fixture_dir}/github/runs.json") }
  let(:test_checks_response_body) { File.read("#{fixture_dir}/github/check_runs.json") }
  let(:test_annotations_response_body) { File.read("#{fixture_dir}/github/annotations.json") }
  let(:test_manager) { described_class.new("github", plugin_branch, discourse_branch) }
  let(:status) { PluginManager::Plugin::Status.get(compatible_plugin, plugin_branch, discourse_branch) }

  def set_workflow(index, key, value)
    test_response_json = JSON.parse(test_response_body)
    test_response_json['workflow_runs'][index][key] = value
    stub_github_test_request(JSON.generate(test_response_json))
  end

  def set_test_check(index, key, value)
    test_checks_response_json = JSON.parse(test_checks_response_body)
    test_checks_response_json['check_runs'][index][key] = value
    stub_github_test_check_request(JSON.generate(test_checks_response_json))
  end

  before do
    stub_github_user_request
    stub_github_plugin_request
    stub_github_test_request(test_response_body)
    PluginManager.stubs(:root_dir).returns(fixture_dir)
    setup_test_plugin(compatible_plugin)
  end

  it "does nothing if plugin is not using Discourse Plugin workflow" do
    set_workflow(0, 'name', 'Plugin Tests')
    test_manager.update(compatible_plugin)
    expect(status.test_status).to eq(nil)
  end

  it "sets a passing test status when tests are passing" do
    test_manager.update(compatible_plugin)
    expect(status.test_status).to eq(described_class.status[:passing])
  end

  it "sets a passing test status when linting is failing" do
    set_workflow(0, 'conclusion', 'failure')
    set_test_check(0, 'conclusion', 'failure')

    test_manager.update(compatible_plugin)
    expect(status.test_status).to eq(described_class.status[:passing])
  end

  it "sets a failing status and message when tests are failing" do
    PluginManager::Plugin::Status.update(compatible_plugin, git, compatible_status)

    set_workflow(0, 'conclusion', 'failure')
    set_test_check(2, 'conclusion', 'failure')
    stub_github_annotations_request(test_annotations_response_body)

    PluginManager::StatusHandler.any_instance.expects(:perform).with(
      PluginManager::Plugin::Status.statuses[:compatible],
      PluginManager::Plugin::Status.statuses[:tests_failing],
      {
        message: I18n.t("plugin_manager.test.failed_with_message",
          test_name: "ci / frontend_tests",
          message: "QUnit Test Failure: Acceptance: Field | Fields: Text, Process completed with exit code 1."
        )
      }
    ).returns(true)

    test_manager.update(compatible_plugin)
    expect(status.test_status).to eq(described_class.status[:failing])
  end
end

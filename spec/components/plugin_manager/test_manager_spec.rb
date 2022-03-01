# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::TestManager do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:incompatible_plugin) { "incompatible_plugin" }
  let(:test_response_body) { File.read("#{fixture_dir}/github/runs.json") }

  before do
    stub_github_user_request
    stub_github_plugin_request
    stub_github_test_request(test_response_body)
    PluginManager.stubs(:root_dir).returns(fixture_dir)
    setup_test_plugin(compatible_plugin)
  end

  it "updates plugin tests" do
    manager = described_class.new("github", plugin_branch, discourse_branch)
    manager.update(compatible_plugin)

    status = PluginManager::Plugin::Status.get(compatible_plugin, plugin_branch, discourse_branch)
    expect(status.test_status).to eq(described_class.status[:passing])

    test_response_json = JSON.parse(test_response_body)
    test_response_json['workflow_runs'][0]['conclusion'] = 'failure'
    stub_github_test_request(JSON.generate(test_response_json))
    manager.update(compatible_plugin)

    status = PluginManager::Plugin::Status.get(compatible_plugin, plugin_branch, discourse_branch)
    expect(status.test_status).to eq(described_class.status[:failing])
  end
end

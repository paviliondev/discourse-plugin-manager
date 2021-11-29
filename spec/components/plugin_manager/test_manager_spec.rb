# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::TestManager do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:incompatible_plugin) { "incompatible_plugin" }
  let(:test_response_body) { File.read("#{fixture_dir}/github/discourse-compatible-plugin.json") }

  before do
    stub_github_user_request
    stub_github_test_request(test_response_body)
    PluginManager.stubs(:root_dir).returns(fixture_dir)
    PluginManager::Plugin.set_from_file(plugin_dir(compatible_plugin))
  end

  it "updates plugin tests" do
    manager = PluginManager::TestManager.new("github")
    manager.update(compatible_plugin)

    plugin = PluginManager::Plugin.get(compatible_plugin)
    expect(plugin.test_status).to eq(PluginManager::TestManager.status[:passing])
    expect(plugin.test_backend_coverage).to eq(92.45)

    test_response_json = JSON.parse(test_response_body)
    test_response_json['workflow_runs'][0]['conclusion'] = 'failure'
    stub_github_test_request(JSON.generate(test_response_json))
    manager.update(compatible_plugin)

    plugin = PluginManager::Plugin.get(compatible_plugin)
    expect(plugin.test_status).to eq(PluginManager::TestManager.status[:failing])
  end
end
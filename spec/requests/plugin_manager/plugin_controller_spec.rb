# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::PluginController do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:third_party_plugin) { "third_party_plugin" }

  before do
    stub_github_user_request
    stub_github_plugin_request
    setup_test_plugin(compatible_plugin)
    setup_test_plugin(third_party_plugin)
  end

  it "indexes plugins" do
    get "/plugin-manager/plugin.json"

    expect(response.status).to eq(200)
    expect(response.parsed_body['plugins'].length).to eq(2)
    expect(response.parsed_body['plugins'].first['status']['status']).to eq('compatible')
  end

  it "indexes plugins with statuses filtered by discourse branch" do
    PluginManager::Plugin::Status.update(
      compatible_plugin,
      "main",
      "stable",
      status: PluginManager::Plugin::Status.statuses[:incompatible]
    )

    get "/plugin-manager/plugin.json", params: { branch: 'stable' }

    expect(response.status).to eq(200)

    plugins = response.parsed_body['plugins']
    expect(plugins.length).to eq(2)
    expect(plugins.select { |p| p['name'] === compatible_plugin }.first['status']['status']).to eq('incompatible')
    expect(plugins.select { |p| p['name'] === third_party_plugin }.first['status']['status']).to eq('unknown')
  end
end

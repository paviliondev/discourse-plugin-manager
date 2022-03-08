# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::PluginController do
  let(:new_plugin_sha) { "36e7163d164fe7ecf02928c42255412edda544f4" }
  let(:new_discourse_sha) { "a7db0ce985aa61a6d323cde010e7f47ab4f46696" }

  before do
    stub_github_user_request
    stub_github_plugin_request
    setup_test_plugin(compatible_plugin)
    setup_test_plugin(third_party_plugin)
    PluginManager::Plugin::Status.update(compatible_plugin, git, compatible_status)
    PluginManager::Plugin::Status.update(third_party_plugin, git, compatible_status)
  end

  it "indexes plugins" do
    get "/plugin-manager/plugin.json"

    expect(response.status).to eq(200)
    expect(response.parsed_body['plugins'].length).to eq(2)
    expect(response.parsed_body['plugins'].first['status']['status']).to eq('compatible')
  end

  it "indexes plugins with statuses filtered by discourse branch" do
    get "/plugin-manager/plugin.json", params: { branch: plugin_branch }

    expect(response.status).to eq(200)

    plugins = response.parsed_body['plugins']
    expect(plugins.length).to eq(2)
    expect(plugins.select { |p| p['name'] === compatible_plugin }.first['status']['status']).to eq('compatible')
    expect(plugins.select { |p| p['name'] === third_party_plugin }.first['status']['status']).to eq('compatible')
  end
end

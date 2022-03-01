# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::PluginStatusController do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:third_party_plugin) { "third_party_plugin" }

  before do
    stub_github_user_request
    stub_github_plugin_request
  end

  it "indexes plugin statuses" do
    setup_test_plugin(compatible_plugin)
    setup_test_plugin(third_party_plugin)

    get "/plugin-manager/status", params: {
      plugins: [
        {
          name: compatible_plugin,
          branch: 'main',
          discourse_branch: 'main'
        },
        {
          name: third_party_plugin,
          branch: 'main',
          discourse_branch: 'main'
        }
      ]
    }

    expect(response.status).to eq(200)
    expect(response.parsed_body['total']).to eq(2)
    expect(response.parsed_body['statuses'].first['status']).to eq(PluginManager::Plugin::Status.statuses[:compatible])
  end
end

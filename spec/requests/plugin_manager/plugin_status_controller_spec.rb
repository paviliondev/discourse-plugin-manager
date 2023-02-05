# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::PluginStatusController do
  fab!(:user) { Fabricate(:user) }
  let(:new_plugin_sha) { "36e7163d164fe7ecf02928c42255412edda544f4" }
  let(:new_discourse_sha) { "a7db0ce985aa61a6d323cde010e7f47ab4f46696" }

  before do
    stub_github_user_request
    stub_github_plugin_request
  end

  it "indexes plugin statuses" do
    setup_test_plugin(compatible_plugin)
    setup_test_plugin(third_party_plugin)
    freeze_time Time.now
    PluginManager::Plugin::Status.update(compatible_plugin, git, compatible_status)
    PluginManager::Plugin::Status.update(third_party_plugin, git, compatible_status)

    get "/plugin-manager/status", params: {
      plugins: [
        {
          name: compatible_plugin,
          branch: 'main',
          discourse_branch: 'tests-passed'
        },
        {
          name: third_party_plugin,
          branch: 'main',
          discourse_branch: 'tests-passed'
        }
      ]
    }

    expect(response.status).to eq(200)
    expect(response.parsed_body['total']).to eq(2)
    expect(response.parsed_body['statuses'].first['status']).to eq('compatible')
    expect(response.parsed_body['statuses'].first['last_status_at']).to eq(Time.now.strftime('%F %T'))
  end

  it "updates a plugin status" do
    freeze_time 1.day.ago

    setup_test_plugin(compatible_plugin)

    freeze_time 1.day.from_now

    create_commits_record

    api_key = ApiKey.create!(user_id: user.id, created_by_id: -1)

    post "/plugin-manager/status",
      headers: {
        "HTTP_API_KEY" => api_key.key
      },
      params: {
        plugins: [
          {
            name: compatible_plugin,
            branch: 'main',
            sha: new_plugin_sha,
            status: PluginManager::Plugin::Status.statuses[:incompatible],
            message: "#{compatible_plugin.titleize} broke",
            backtrace: "broken at line 123"
          }
        ],
        discourse: {
          branch: 'tests-passed',
          sha: discourse_sha
        }
      }

    expect(response.status).to eq(200)
    expect(response.parsed_body['success']).to eq("OK")

    expect(
      PluginManager::Plugin::Status.get(compatible_plugin, plugin_branch, discourse_branch).status
    ).to eq(PluginManager::Plugin::Status.statuses[:incompatible])
    expect(
      PluginManager::Log.get_unresolved(compatible_plugin, git).message
    ).to eq("#{compatible_plugin.titleize} broke")
  end
end

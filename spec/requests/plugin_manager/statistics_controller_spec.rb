# frozen_string_literal: true

describe PluginManager::StatisticsController do
  let(:registered_plugin) { compatible_plugin }
  let(:non_registered_plugin) { third_party_plugin }
  let(:plugin_sha) { "12345678910" }
  let(:plugin_branch) { "plugin_branch" }
  let(:plugin_data) do
    {
      data_key_1: "data-val-1",
      data_key_2: "data-val-2"
    }
  end
  let(:discourse_sha) { "678910" }
  let(:discourse_branch) { "discourse_branch" }
  let(:discourse_host) { "forum.external.com" }
  let(:params) do
    {
      discourse: {
        host: discourse_host,
        branch: discourse_branch,
        sha: discourse_sha
      },
      plugins: [
        {
          name: registered_plugin,
          branch: plugin_branch,
          sha: plugin_sha,
          data: plugin_data
        }
      ]
    }
  end

  before do
    stub_github_plugin_request
    stub_github_user_request
    setup_test_plugin(registered_plugin)
    freeze_time
  end

  describe "#process" do
    it "requires valid params" do
      post "/plugin-manager/statistics"
      expect(response).not_to be_successful
    end

    context "with a new discourse" do
      it "creates a new discourse record" do
        post "/plugin-manager/statistics", params: params
        expect(response).to be_successful
        expect(
          DiscoursePluginStatisticsDiscourse.exists?(
            host: discourse_host,
            branch: discourse_branch,
            sha: discourse_sha
          )
        ).to eq(true)
      end
    end

    context "with an existing discourse" do
      let!(:discourse) { Fabricate(:discourse_plugin_statistics_discourse, host: discourse_host) }

      it "updates the existing discourse record" do
        new_sha = "11121314"
        params[:discourse][:sha] = new_sha
        post "/plugin-manager/statistics", params: params
        expect(response).to be_successful
        expect(
          DiscoursePluginStatisticsDiscourse.exists?(
            host: discourse_host,
            branch: discourse_branch,
            sha: new_sha
          )
        ).to eq(true)
        expect(
          DiscoursePluginStatisticsDiscourse.where(host: discourse_host).size
        ).to eq(1)
      end
    end

    context "with a registered plugin" do
      it "saves a new plugin record" do
        post "/plugin-manager/statistics", params: params
        expect(response).to be_successful

        discourse = DiscoursePluginStatisticsDiscourse.find_by(host: discourse_host)
        expect(
          DiscoursePluginStatisticsPlugin.exists?(
            received_at: Time.now,
            discourse_id: discourse.id,
            name: registered_plugin,
            branch: plugin_branch,
            sha: plugin_sha
          )
        ).to eq(true)
      end
    end

    context "with a non-reigstered plugin" do
      it "does not save a new plugin record" do
        params[:plugins][0][:name] = non_registered_plugin
        post "/plugin-manager/statistics", params: params
        expect(response).to be_successful

        discourse = DiscoursePluginStatisticsDiscourse.find_by(host: discourse_host)
        expect(
          DiscoursePluginStatisticsPlugin.exists?(
            received_at: Time.now,
            discourse_id: discourse.id,
            name: non_registered_plugin,
            branch: plugin_branch,
            sha: plugin_sha
          )
        ).to eq(false)
      end
    end
  end
end

# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginGuard::Handler do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:compatible_plugin_url) { "https://github.com/paviliondev/discourse-compatible-plugin.git" }
  let(:third_party_plugin) { "third_party_plugin" }
  let(:third_party_user) { "angusmcleod" }
  let(:domain) { "thepavilion.test" }
  let(:base_url) { "https://#{domain}" }
  let(:api_user) { "angus" }
  let(:api_token) { "12345" }
  let(:response_post) { JSON.parse(File.open("#{fixture_dir}/discourse/post.json").read) }

  before do
    SiteSetting.plugin_manager_issue_management_site_base_url = base_url
    SiteSetting.plugin_manager_issue_management_site_api_user = api_user
    SiteSetting.plugin_manager_issue_management_site_api_token = api_token
  end

  def stub_post_request(request_body, response_body)
    stub_request(:post, "#{base_url}/posts").with(
      body: request_body.to_json,
      headers: {
        'Api-Key' => api_token,
        'Api-Username' => api_user,
        'Content-Type' => 'application/json',
        'Host' => domain
      }
    ).to_return(
      status: 200,
      body: response_body.to_json
    )
  end

  def add_log(plugin)
    PluginGuard::Log.add(
      plugin_name: plugin,
      message: "#{plugin.titleize} broke",
      backtrace: "broken at line 123",
      status: PluginManager::Manifest.status[:incompatible]
    )
  end

  def get_log(plugin, status)
    log_key = PluginGuard::Log.key(plugin, status, plugin_sha, Discourse.git_version)
    PluginGuard::Log.get(log_key)
  end

  it "sets plugin from file" do
    stub_github_user_request
    setup_test_plugin(compatible_plugin)

    plugin = PluginManager::Plugin.get(compatible_plugin)
    expect(plugin.name).to eq(compatible_plugin)
  end

  it "retrieves plugin from url" do
    stub_github_plugin_file_request

    result = PluginManager::Plugin.retrieve_from_url(compatible_plugin_url, plugin_branch)
    expect(result.plugin[:name]).to eq(compatible_plugin)
    expect(result.plugin[:about]).to eq("Compatbile plugin fixture")
    expect(result.plugin[:version]).to eq("0.1.1")
    expect(result.plugin[:authors]).to eq("Angus McLeod")
    expect(result.plugin[:contact_emails]).to eq("angus@test.com")
  end

  context "status change" do
    context "non pavilion plugin" do
      before do
        stub_github_user_request(third_party_user)
        setup_test_plugin(third_party_plugin, "https://github.com/#{third_party_user}/discourse-#{third_party_plugin.dasherize}.git")
        add_log(third_party_plugin)
      end

      it "sends an email if broken" do
        expect_enqueued_with(job: :send_plugin_notification, args: {
          plugin: third_party_plugin,
          site: SiteSetting.title,
          contact_emails: "angus@test.com",
          title: I18n.t("plugin_manager.notifier.broken.title", plugin_name: third_party_plugin.titleize)
        }) do
          PluginManager::Plugin.set(third_party_plugin, status: ::PluginManager::Manifest.status[:incompatible])
        end
      end
    end

    context "pavilion plugin" do
      before do
        stub_github_user_request
        setup_test_plugin(compatible_plugin)
        add_log(compatible_plugin)

        log = get_log(compatible_plugin, PluginManager::Manifest.status[:incompatible])
        request_body = {
          title: PluginManager::Notifier.title('broken', compatible_plugin.titleize),
          raw: PluginManager::Notifier.post_markdown('broken', log, compatible_plugin.titleize),
          archetype: "regular",
          tags: ["automated", compatible_plugin],
          category: 1
        }
        stub_post_request(request_body, response_post)
      end

      it "posts to server if broken" do
        PluginManager::Plugin.set(compatible_plugin, status: ::PluginManager::Manifest.status[:incompatible])
        expect(WebMock).to have_requested(
          :post,
          "#{base_url}/posts",
        ).with(
          headers: {
            "Content-Type" => "application/json",
            "Api-Username" => "#{api_user}",
            "Api-Key" => "#{api_token}"
          }
        )
      end

      it "posts to server if fixed" do
        PluginManager::Plugin.set(compatible_plugin, status: ::PluginManager::Manifest.status[:incompatible])

        log = get_log(compatible_plugin, PluginManager::Manifest.status[:incompatible])
        request_body = {
          title: PluginManager::Notifier.title('fixed', compatible_plugin.titleize),
          raw: PluginManager::Notifier.post_markdown('fixed', log, compatible_plugin.titleize),
          archetype: "regular",
          topic_id: response_post['topic_id']
        }
        stub_post_request(request_body, response_post)

        PluginManager::Plugin.set(compatible_plugin, status: ::PluginManager::Manifest.status[:compatible])

        expect(WebMock).to have_requested(
          :post,
          "#{base_url}/posts",
        ).with(
          headers: {
            "Content-Type" => "application/json",
            "Api-Username" => "#{api_user}",
            "Api-Key" => "#{api_token}"
          }
        ).twice
      end
    end
  end
end

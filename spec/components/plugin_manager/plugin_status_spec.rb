# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::Plugin::Status do
  it "updates a plugin status" do
    described_class.update(compatible_plugin, git, compatible_status)

    expect(
      described_class.get(compatible_plugin, plugin_branch, discourse_branch).status
    ).to eq(described_class.statuses[:compatible])
  end

  it "lists plugin statuses" do
    described_class.update(compatible_plugin, git, compatible_status)
    described_class.update(incompatible_plugin, git, incompatible_status)

    expect(described_class.list.total).to eq(2)
    expect(described_class.list.statuses.first.status).to eq(described_class.statuses[:compatible])
    expect(described_class.list.statuses.second.status).to eq(described_class.statuses[:incompatible])
  end

  it "updates test status attributes" do
    stub_github_plugin_request
    stub_github_user_request
    setup_test_plugin(compatible_plugin)

    freeze_time Time.now

    create_commits_record

    freeze_time 1.day.ago

    described_class.update(compatible_plugin, git, compatible_status)

    freeze_time Time.now

    new_git_attrs = git.dup
    new_git_attrs[:sha] = new_plugin_sha
    described_class.update(compatible_plugin, new_git_attrs, test_status: PluginManager::TestManager.status[:failing])

    expect(
      described_class.get(compatible_plugin, plugin_branch, discourse_branch).status
    ).to eq(described_class.statuses[:tests_failing])
  end

  context "status change" do
    before do
      SiteSetting.plugin_manager_issue_management_site_base_url = base_url
      SiteSetting.plugin_manager_issue_management_site_api_user = api_user
      SiteSetting.plugin_manager_issue_management_site_api_token = api_token
    end

    def add_log(plugin)
      PluginManager::Log.add(plugin, git,
        message: "#{plugin.titleize} broke",
        backtrace: "broken at line 123",
        status: described_class.statuses[:incompatible]
      )
    end

    context "non pavilion plugin" do
      let(:third_party_user) { "angusmcleod" }

      before do
        stub_github_user_request(third_party_user)
        stub_github_plugin_request(third_party_user, third_party_plugin)
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
          described_class.update(third_party_plugin, git, incompatible_status.merge(skip_git_check: true))
        end
      end
    end

    context "pavilion plugin" do
      let(:response_post) { JSON.parse(File.open("#{fixture_dir}/discourse/post.json").read) }

      before do
        stub_github_user_request
        stub_github_plugin_request
        setup_test_plugin(compatible_plugin)

        log = add_log(compatible_plugin)
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
        described_class.update(compatible_plugin, git, incompatible_status.merge(skip_git_check: true))

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
        freeze_time

        described_class.update(compatible_plugin, git, incompatible_status.merge(skip_git_check: true))

        log = add_log(compatible_plugin)
        request_body = {
          title: PluginManager::Notifier.title('fixed', compatible_plugin.titleize),
          raw: PluginManager::Notifier.post_markdown('fixed', log, compatible_plugin.titleize),
          archetype: "regular",
          topic_id: response_post['topic_id']
        }
        stub_post_request(request_body, response_post)

        described_class.update(compatible_plugin, git, compatible_status.merge(skip_git_check: true))

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

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
    expect(
      described_class.get(compatible_plugin, plugin_branch, discourse_branch).last_status_at.to_time.strftime('%F %T')
    ).to eq(Time.now.strftime('%F %T'))
  end

  context "with status change" do
    def add_log(plugin)
      PluginManager::Log.add(plugin, git,
        message: "#{plugin.titleize} broke",
        backtrace: "broken at line 123",
        status: described_class.statuses[:incompatible]
      )
    end

    context "without posting enabled" do
      let(:third_party_user) { "angusmcleod" }

      before do
        SiteSetting.plugin_manager_remote_issues = true
        stub_github_user_request(third_party_user)
        stub_github_plugin_request(third_party_user, third_party_plugin)
        setup_test_plugin(third_party_plugin, plugin_url: "https://github.com/#{third_party_user}/discourse-#{third_party_plugin.dasherize}.git")
      end

      it "sends an email" do
        log = add_log(third_party_plugin)
        expect_enqueued_with(job: :send_plugin_notification, args: {
          plugin: third_party_plugin,
          site: SiteSetting.title,
          contact_emails: "angus@test.com",
          title: I18n.t("plugin_manager.notifier.broken.title",
            plugin_name: third_party_plugin.titleize,
            discourse_branch: log.discourse_branch,
            plugin_branch: log.branch
          )
        }) do
          described_class.update(third_party_plugin, git, incompatible_status.merge(skip_git_check: true))
        end
      end
    end

    context "with remote posting enabled" do
      let(:response_post) { JSON.parse(File.open("#{fixture_dir}/discourse/post.json").read) }

      before do
        skip("not currently implemented")

        SiteSetting.plugin_manager_remote_issues_site_base_url = base_url
        SiteSetting.plugin_manager_remote_issues_site_api_user = api_user
        SiteSetting.plugin_manager_remote_issues_site_api_token = api_token
        SiteSetting.plugin_manager_remote_issues = false
        stub_github_user_request
        stub_github_plugin_request
        plugin = setup_test_plugin(compatible_plugin, setup_categories: true)

        log = add_log(compatible_plugin)
        request_body = {
          raw: PluginManager::Notifier.post_markdown(:broken, log, compatible_plugin.titleize),
          title: PluginManager::Notifier.title(:broken, log, compatible_plugin.titleize),
          archetype: "regular",
          category: plugin.support_category_id,
          tags: ["automated", compatible_plugin, log.branch]
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
          raw: PluginManager::Notifier.post_markdown(:fixed, log, compatible_plugin.titleize),
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

    context "with local posting enabled" do
      before do
        stub_github_user_request
        stub_github_plugin_request

        freeze_time
        @plugin = setup_test_plugin(compatible_plugin, setup_categories: true)
        add_log(compatible_plugin)
      end

      it "creates a topic if broken" do
        described_class.update(compatible_plugin, git, incompatible_status.merge(skip_git_check: true))

        log = PluginManager::Log.get_unresolved(compatible_plugin, git)
        plugin_name = compatible_plugin.titleize
        topic = Topic.find(log.issue_id)
        title = PluginManager::Notifier.title(:broken, log, plugin_name)
        post_markdown = PluginManager::Notifier.post_markdown(:broken, log, plugin_name)
        category_id = Category.find_by(id: @plugin.support_category_id).id

        expect(topic.present?).to eq(true)
        expect(topic.title).to eq(title)
        expect(topic.category_id).to eq(category_id)
        expect(topic.first_post.raw).to eq(post_markdown.strip)
      end

      it "creates a post and closes topic if fixed" do
        described_class.update(compatible_plugin, git, incompatible_status.merge(skip_git_check: true))
        described_class.update(compatible_plugin, git, compatible_status.merge(skip_git_check: true))

        log = PluginManager::Log.get_resolved(compatible_plugin, git)
        topic = Topic.find(log.issue_id)
        expect(topic.closed?).to eq(true)
      end

      it "does not create a post and close topic if tests are failing" do
        described_class.update(compatible_plugin, git, incompatible_status.merge(skip_git_check: true))
        described_class.update(compatible_plugin, git, tests_failing.merge(skip_git_check: true))

        log = PluginManager::Log.get_unresolved(compatible_plugin, git)
        topic = Topic.find(log.issue_id)
        expect(topic.open?).to eq(true)
      end
    end
  end
end

# frozen_string_literal: true

if ENV['SIMPLECOV']
  require 'simplecov'

  SimpleCov.start do
    root "plugins/discourse-plugin-manager"
    track_files "plugins/discourse-plugin-manager/**/*.rb"
    add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
  end
end

def fixture_dir
  "#{Rails.root}/plugins/discourse-plugin-manager/spec/fixtures"
end

def plugin_dir(name, compatible: true)
  plugins_dir = compatible ? PluginManager.compatible_dir : PluginManager.incompatible_dir
  "#{fixture_dir}/#{plugins_dir}/#{name}"
end

def plugin_url
  "https://github.com/paviliondev/discourse-compatible-plugin"
end

def plugin_sha
  "d5f7a1dbe5fcd9513aebad188e677a89fe955d86"
end

def new_plugin_sha
  "36e7163d164fe7ecf02928c42255412edda544f4"
end

def plugin_branch
  "main"
end

def discourse_url
  "https://github.com/discourse/discourse"
end

def discourse_sha
  "eb2e3b510de9295d1ed91919d2df0dc800364689"
end

def new_discourse_sha
  "a7db0ce985aa61a6d323cde010e7f47ab4f46696"
end

def discourse_branch
  "tests-passed"
end

def compatible_plugin
  "compatible_plugin"
end

def incompatible_plugin
  "incompatible_plugin"
end

def third_party_plugin
  "third_party_plugin"
end

def git
  {
    branch: plugin_branch,
    sha: plugin_sha,
    discourse_branch: discourse_branch,
    discourse_sha: discourse_sha
  }
end

def domain
  "thepavilion.test"
end

def base_url
  "https://#{domain}"
end

def api_user
  "angus"
end

def api_token
  "12345"
end

def stub_plugin_git_cmds(dir, plugin_url)
  Open3.expects(:capture3).with("git rev-parse HEAD", chdir: dir).returns(plugin_sha).at_least_once
  Open3.expects(:capture3).with("git rev-parse --abbrev-ref HEAD", chdir: dir).returns(plugin_branch).at_least_once
  Open3.expects(:capture3).with("git config --get remote.origin.url", chdir: dir).returns(plugin_url || "https://github.com/paviliondev/discourse-compatible-plugin.git")
  Discourse.expects(:git_branch).returns(discourse_branch).at_least_once
  Discourse.expects(:git_version).returns(discourse_sha).at_least_once
end

def setup_test_plugin(name, plugin_url: nil, setup_category: false)
  dir = plugin_dir(name)
  stub_plugin_git_cmds(dir, plugin_url)
  PluginManager::TestHost.expects(:detect_local).returns("github")
  plugin = PluginManager::Plugin.set_local(dir)

  if setup_category
    category = Fabricate(:category)
    plugin = PluginManager::Plugin.set(plugin.name, category_id: category.id)
    local_management = SiteSetting.plugin_manager_issue_management_local
    subcategory_name = SiteSetting.plugin_manager_issue_management_local_subcategory_name

    if local_management && subcategory_name.present?
      Fabricate(:category, parent_category_id: plugin.category_id, name: subcategory_name)
    end
  end

  plugin
end

def stub_github_user_request(user = "paviliondev")
  stub_request(:get, "https://api.github.com/users/#{user}").to_return(
    status: 200,
    body: File.read("#{fixture_dir}/github/#{user}.json")
  )
end

def stub_github_plugin_request(user = "paviliondev", plugin_path = "compatible-plugin")
  stub_request(:get, "https://api.github.com/repos/#{user}/discourse-#{plugin_path.dasherize}").to_return(
    status: 200,
    body: File.read("#{fixture_dir}/github/#{plugin_path.dasherize}.json")
  )
end

def stub_github_plugin_file_request
  plugin_path = "discourse-compatible-plugin"
  stub_request(:get, "https://api.github.com/repos/paviliondev/#{plugin_path}/contents/plugin.rb?ref=#{plugin_branch}").to_return(
    status: 200,
    body: File.read("#{fixture_dir}/github/plugin.json")
  )
end

def stub_github_test_request(response_body)
  plugin_path = "discourse-compatible-plugin"
  stub_request(:get, "https://api.github.com/repos/paviliondev/#{plugin_path}/actions/runs?branch=#{plugin_branch}&status=completed&per_page=1&page=1").to_return(
    status: 200,
    body: response_body
  )
end

def stub_commits_url(since: nil, ref: nil, sha: nil, commits: nil, branch: nil, url: nil)
  host = PluginManager::RepositoryHost::Github.new
  host.url = url || plugin_url
  host.branch = branch || plugin_branch
  url = "https://" + host.domain + "/" + host.commits_path(since: since, ref: ref, sha: sha)
  body = commits.map { |c| { sha: c[:sha], commit: { committer: { date: c[:date] } } } }
  stub_request(:get, url).to_return(body: body.to_json)
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
    body: response_body.to_json,
    headers: {}
  )
end

def create_commits_record(plugin_sha = nil)
  stub_commits_url(
    sha: plugin_branch,
    since: 1.day.ago.iso8601(3),
    commits: [ { sha: plugin_sha || new_plugin_sha, date: 1.minute.ago.iso8601(3) } ]
  )
  stub_commits_url(
    url: discourse_url,
    branch: discourse_branch,
    sha: discourse_branch,
    since: 1.day.ago.iso8601(3),
    commits: [ { sha: new_discourse_sha, date: 1.minute.ago.iso8601(3) } ]
  )
end

def compatible_status
  { status: PluginManager::Plugin::Status.statuses[:compatible] }
end

def incompatible_status
  { status: PluginManager::Plugin::Status.statuses[:incompatible] }
end

require 'rails_helper'

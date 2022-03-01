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

def plugin_sha
  "d5f7a1dbe5fcd9513aebad188e677a89fe955d86"
end

def plugin_branch
  "main"
end

def discourse_branch
  "main"
end

def stub_plugin_git_cmds(dir, plugin_url)
  Open3.expects(:capture3).with("git rev-parse --abbrev-ref HEAD", chdir: dir).returns(plugin_branch).at_least_once
  Open3.expects(:capture3).with("git config --get remote.origin.url", chdir: dir).returns(plugin_url || "https://github.com/paviliondev/discourse-compatible-plugin.git")
end

def setup_test_plugin(name, plugin_url = nil)
  dir = plugin_dir(name)
  stub_plugin_git_cmds(dir, plugin_url)
  PluginManager::TestHost.expects(:detect_local).returns("github")
  PluginManager::Plugin.set_local(dir)
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

require 'rails_helper'

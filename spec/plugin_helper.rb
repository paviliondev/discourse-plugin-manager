# frozen_string_literal: true

if ENV['SIMPLECOV']
  require 'simplecov'

  SimpleCov.start do
    root "plugins/discourse-plugin-manager-server"
    track_files "plugins/discourse-plugin-manager-server/**/*.rb"
    add_filter { |src| src.filename =~ /(\/spec\/|\/db\/|plugin\.rb)/ }
  end
end

def fixture_dir
  "#{Rails.root}/plugins/discourse-plugin-manager-server/spec/fixtures"
end

def plugin_dir(name, compatible: true)
  plugins_dir = compatible ? PluginManager.compatible_dir : PluginManager.incompatible_dir
  "#{fixture_dir}/#{plugins_dir}/#{name}"
end

def stub_github_user_request
  stub_request(:get, "https://api.github.com/users/paviliondev").to_return(
    status: 200,
    body: File.read("#{fixture_dir}/github/paviliondev.json")
  )
end

def stub_github_test_request(response_body)
  plugin_path = "discourse-compatible-plugin"
  branch = "main"
  stub_request(:get, "https://api.github.com/repos/paviliondev/#{plugin_path}/actions/runs?branch=#{branch}&status=completed&per_page=1&page=1").to_return(
    status: 200,
    body: response_body
  )
end

require 'rails_helper'
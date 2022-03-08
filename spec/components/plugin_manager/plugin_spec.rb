# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::Plugin do
  it "sets plugin from file" do
    stub_github_user_request
    stub_github_plugin_request
    setup_test_plugin(compatible_plugin)

    plugin = described_class.get(compatible_plugin)
    expect(plugin.name).to eq(compatible_plugin)
  end

  it "retrieves plugin from url" do
    stub_github_plugin_file_request

    result = described_class.retrieve_from_url(plugin_url, plugin_branch)
    expect(result.plugin[:name]).to eq(compatible_plugin)
    expect(result.plugin[:about]).to eq("Compatbile plugin fixture")
    expect(result.plugin[:authors]).to eq("Angus McLeod")
    expect(result.plugin[:contact_emails]).to eq("angus@test.com")
  end
end

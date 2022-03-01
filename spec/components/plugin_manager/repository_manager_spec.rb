# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::RepositoryManager do
  let(:compatible_plugin) { "compatible_plugin" }

  before do
    stub_github_user_request
    stub_github_plugin_request
    setup_test_plugin(compatible_plugin)
  end

  it "gets plugin owner" do
    plugin = PluginManager::Plugin.get(compatible_plugin)
    manager = described_class.new(plugin.url, plugin.branch)
    owner = manager.get_owner
    expect(owner.name).to eq("Pavilion")
  end
end

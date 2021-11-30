# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::RepositoryManager do
  let(:compatible_plugin) { "compatible_plugin" }

  before do
    stub_github_user_request
    setup_test_plugin(compatible_plugin)
  end

  it "gets plugin owner" do
    manager = PluginManager::RepositoryManager.new("github")
    owner = manager.get_owner(compatible_plugin)
    expect(owner.name).to eq("Pavilion")
  end
end

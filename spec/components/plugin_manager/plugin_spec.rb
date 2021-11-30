# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginGuard::Handler do
  let(:compatible_plugin) { "compatible_plugin" }

  before do
    stub_github_user_request
    setup_test_plugin(compatible_plugin)
  end

  it "sets plugin from file" do
    plugin = PluginManager::Plugin.get(compatible_plugin)
    expect(plugin.name).to eq(compatible_plugin)
  end
end

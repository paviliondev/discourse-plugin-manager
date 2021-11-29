# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginGuard::Handler do
  let(:compatible_plugin) { "compatible_plugin" }
  let(:incompatible_plugin) { "incompatible_plugin" }

  before do
    stub_github_user_request
    PluginManager::Plugin.set_from_file(plugin_dir(compatible_plugin))
  end

  it "sets plugin from file" do
    expect(PluginManager::Plugin.get(compatible_plugin).name).to eq(compatible_plugin)
  end
end

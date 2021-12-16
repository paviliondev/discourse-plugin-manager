# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginGuard::Handler do
  let(:incompatible_plugin) { "incompatible_plugin" }

  before do
    stub_github_user_request
    setup_test_plugin(incompatible_plugin, "https://github.com/paviliondev/discourse-incompatible-plugin.git")
  end

  it "#perform" do
    FileUtils.stubs(:mv).with(
      plugin_dir(incompatible_plugin),
      plugin_dir(incompatible_plugin, compatible: false),
      force: true
    )

    guard = PluginGuard.new(plugin_dir(incompatible_plugin))
    handler = described_class.new(incompatible_plugin, plugin_dir(incompatible_plugin))
    handler.perform('Failed to load', 'backtrace', guard.precompiled_assets, plugin_sha, plugin_branch)

    expect(Discourse.plugins.select { |p| p.metadata.name == incompatible_plugin }.size).to eq(0)
    expect(PluginGuard::Log.list(incompatible_plugin).size).to eq(1)
  end
end

# frozen_string_literal: true
require_relative '../plugin_helper'

describe PluginGuard do
  let(:compatible_plugin) { "compatible_plugin" }

  before do
    stub_github_user_request
    setup_test_plugin(compatible_plugin)
  end

  it "obtains git details on initialization" do
    guard = described_class.new(plugin_dir(compatible_plugin))
    expect(guard.metadata.name).to eq(compatible_plugin)
    expect(guard.sha).to eq(plugin_sha)
    expect(guard.branch).to eq(plugin_branch)
  end
end

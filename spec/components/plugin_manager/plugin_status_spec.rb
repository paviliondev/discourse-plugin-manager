# frozen_string_literal: true
require_relative '../../plugin_helper'

describe PluginManager::Plugin::Status do
  it "updates a plugin status" do
    described_class.update("my_plugin", "main", "main", status: described_class.statuses[:compatible])
    expect(
      described_class.get("my_plugin", "main", "main").status
    ).to eq(described_class.statuses[:compatible])
  end

  it "lists plugin statuses" do
    described_class.update("working-plugin", "main", "main", status: described_class.statuses[:compatible])
    described_class.update("broken-plugin", "main", "main", status: described_class.statuses[:incompatible])

    status_keys = [
      described_class.status_key("working-plugin", "main", "main"),
      described_class.status_key("broken-plugin", "main", "main"),
    ]
    status_list = described_class.list(keys: status_keys, page: nil)
    expect(status_list.statuses.length).to eq(2)
  end

  it "updates test status attributes" do
    described_class.update("my_plugin", "main", "main", status: described_class.statuses[:compatible])
    described_class.update("my_plugin", "main", "main", test_status: PluginManager::TestManager.status[:failing])
    expect(
      described_class.get("my_plugin", "main", "main").status
    ).to eq(described_class.statuses[:tests_failing])
  end
end

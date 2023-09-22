# frozen_string_literal: true

Fabricator(:discourse_plugin_statistics_plugin) do
  host { "forum.external.com" }
  branch { "main" }
  sha { sequence(:sha) { |i| "#{i}123456" } }
end

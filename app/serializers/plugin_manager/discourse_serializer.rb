# frozen_string_literal: true
class PluginManager::DiscourseSerializer < ApplicationSerializer
  attributes :url,
             :version,
             :sha,
             :git_branch
end

class PluginManager::DiscourseSerializer < ApplicationSerializer
  attributes :url,
             :installed_version,
             :installed_sha,
             :git_branch
end
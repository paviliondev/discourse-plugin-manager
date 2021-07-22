class PluginManager::DiscourseSerializer < ApplicationSerializer
  attributes :git_url,
             :installed_version,
             :installed_sha,
             :git_branch
end
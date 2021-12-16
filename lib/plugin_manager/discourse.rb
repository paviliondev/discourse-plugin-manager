# frozen_string_literal: true
class ::PluginManager::Discourse
  include ActiveModel::Serialization

  GIT_URL ||= "https://github.com/discourse/discourse"

  attr_reader :url,
              :version,
              :sha,
              :git_branch

  def initialize
    @url = GIT_URL

    version = ::DiscourseUpdates.check_version
    @version = version.installed_version
    @sha = version.installed_sha
    @git_branch = version.git_branch
  end
end

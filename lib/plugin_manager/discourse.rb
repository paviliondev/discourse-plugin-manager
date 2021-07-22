class ::PluginManager::Discourse
  include ActiveModel::Serialization

  GIT_URL ||= "https://github.com/discourse/discourse"

  attr_reader :git_url,
              :installed_version,
              :installed_sha,
              :git_branch

  def initialize
    @git_url = GIT_URL

    version = ::DiscourseUpdates.check_version
    @installed_version = version.installed_version
    @installed_sha = version.installed_sha
    @git_branch = version.git_branch
  end
end
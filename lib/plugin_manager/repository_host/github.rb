# frozen_string_literal: true
class PluginManager::RepositoryHost::Github < PluginManager::RepositoryHost
  def initialize
    @name = 'github'
    @domain = 'api.github.com'
    @domain = "#{client_id}:#{client_secret}@#{@domain}" if basic_auth?
  end

  def owner_path
    "users/#{repo_user}"
  end

  def plugin_file_path
    "repos/#{repo_user}/#{repo_name}/contents/plugin.rb?ref=#{@branch}"
  end

  def branch_url
    "#{@url}/tree/#{@branch}"
  end

  def get_owner_from_response(response)
    owner = ::PluginManager::RepositoryOwner.new(
      name: response['name'] || response['login'],
      url: response['html_url'],
      website: response['blog'],
      email: response['email'],
      avatar_url: response['avatar_url'],
      description: response['bio']
    )

    if response['type'].present?
      type = response['type'].downcase
      owner_type = ::PluginManager::RepositoryOwner.types[type.to_sym]
      owner.type = owner_type if owner_type
    end

    owner
  end

  def get_file_from_response(response)
    encoding = response['encoding']

    if encoding == 'base64'
      Base64.decode64(response['content'])
    else
      nil
    end
  end

  def get_sha_from_response(response)
    response['sha']
  end

  def repo_user
    @repo_user ||= URI(@url).path.split('/').reject(&:empty?).first
  end

  def repo_name
    @repo_name ||= begin
      name = URI(@url).path.split('/').reject(&:empty?).second
      name ? name.split('.').first : nil
    end
  end

  def basic_auth?
    client_id.present? && client_secret.present?
  end

  def client_id
    SiteSetting.plugin_manager_github_oauth_client_id
  end

  def client_secret
    SiteSetting.plugin_manager_github_oauth_client_secret
  end
end

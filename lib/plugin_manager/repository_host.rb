# frozen_string_literal: true
class ::PluginManager::RepositoryHost
  attr_reader :name,
              :domain

  attr_accessor :url,
                :branch

  ## overide in child
  def owner_path
    ## path to owner
  end

  ## overide in child
  def plugin_file_path
    ## path to plugin file
  end

  ## overide in child
  def get_owner_from_response(response = {})
    ## retrieve owner from raw response
  end

  ## overide in child
  def get_file_from_response(response = {})
    ## retrieve plugin.rb file contents from raw response
  end

  ## overide in child
  def get_sha_from_response(response = {})
    ## retrieve plugin file sha from raw response
  end

  def self.get(name)
    list.find { |host| host.name == name }
  end

  def self.list
    [
      ::PluginManager::RepositoryHost::Github.new
    ]
  end

  def self.get_name(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host = host[4..-1] if host.start_with?('www.')
    host.split('.').first
  end
end

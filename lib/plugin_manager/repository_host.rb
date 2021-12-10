# frozen_string_literal: true
class ::PluginManager::RepositoryHost
  attr_reader :name,
              :domain

  attr_accessor :url,
                :branch

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

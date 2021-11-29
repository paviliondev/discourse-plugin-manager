# frozen_string_literal: true
class ::PluginManager::TestHost
  attr_reader :name,
              :config,
              :domain,
              :branch,
              :test_sha,
              :test_branch,
              :test_name,
              :test_url

  attr_accessor :plugin,
                :branch

  def get_status_from_response
    PluginManager::TestManager.status[:failing]
  end

  def get_status_path(plugin)
    nil
  end

  def self.get(host_name)
    self.list.find { |host| host.name == host_name }
  end

  def self.list
    [
      ::PluginManager::TestHost::Github.new
    ]
  end

  def self.detect
    host = self.list.find { |host| File.file?(host.config) }
    host ? host.name : nil
  end
end

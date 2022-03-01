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
                :branch,
                :discourse_branch

  ## overide in child
  def status_path
    ## path of test staus endpoint
  end

  ## overide in child
  def config_path
    ## path of test config
  end

  ## overide in child
  def get_status_from_response(response)
    ## retrieve test status from raw response
    PluginManager::TestManager.status[:failing]
  end

  def self.get(host_name)
    self.list.find { |host| host.name == host_name }
  end

  def self.list
    [
      ::PluginManager::TestHost::Github.new
    ]
  end

  def self.detect(url)
    name = get_name(url)
    host = list.find { |h| h.name == name }
    host ? host.name : nil
  end

  def self.get_name(url)
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    host = URI.parse(url).host.downcase
    host = host[4..-1] if host.start_with?('www.')
    host.split('.').first
  end

  def self.detect_local(path)
    host = self.list.find { |h| File.file?("#{path}/#{h.config}") }
    host ? host.name : nil
  end
end

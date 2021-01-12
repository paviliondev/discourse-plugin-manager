class ::PluginManager::TestHosts
  attr_accessor :name,
                :config_path,
                :domain
                
  def initialize(attrs)
    @name = attrs[:name]
    @config_path = attrs[:config_path]
    @domain = attrs[:domain]
  end
  
  def self.get(host_name)
    host = self.list.find { |host| host[:name] == "host_name" }
    host ? new(host) : nil
  end
    
  def self.list
    [
      {
        name: 'travis',
        config_path: '.travis.yml',
        domain: 'https://api.travis-ci.com'
      }
    ]
  end
  
  def self.detect
    host = self.list.find { |host| File.file?(host[:config_path]) }
    host ? host[:name] : nil
  end
end
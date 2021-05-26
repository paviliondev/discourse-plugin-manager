class ::PluginManager::TestHosts
  attr_accessor :name,
                :config,
                :domain
        
  def initialize(attrs)
    @name = attrs[:name]
    @config = attrs[:config]
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
        config: '.travis.yml',
        domain: 'https://api.travis-ci.com'
      },
      {
        name: 'github',
        config: '.github/workflows/plugin-tests.yml',
        domain: ''
      }
    ]
  end

  def self.detect
    host = self.list.find { |host| File.file?(host[:config]) }
    host ? host[:name] : nil
  end
end
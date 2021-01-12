# frozen_string_literal: true

class ::PluginGuard
  NAMESPACE ||= 'plugin-guard'
  
  attr_reader :file,
              :metadata,
              :path,
              :sha,
              :branch
  
  def initialize(path)
    return false unless File.exists?("#{path}/plugin.rb")
    
    @file = File.read("#{path}/plugin.rb")
    @metadata = ::Plugin::Metadata.parse(file)
    return false if ::Plugin::Metadata::OFFICIAL_PLUGINS.include?(metadata.name)
    
    @path = path
    Dir.chdir(path) do
      @sha = Discourse.try_git('git rev-parse HEAD', nil)
      @branch = Discourse.try_git("git branch | sed -n '/\* /s///p'", 'tests-passed')
    end
  end
  
  def precompiled_assets
    @precompiled_assets ||= begin
      block_start = false
      in_block = false
      result = []
      
      @file.each_line do |line|
        if line.include?("config.assets.precompile")
          block_start = true
          in_block = true
        end
                  
        if in_block && line.include?(".js")
          result += line.scan(/[\w|\-|\_]*\.js.*$/)
        else
          if block_start
            block_start = false
          else
            in_block = false
          end
        end
      end
      
      result
    end
  end
  
  def handle(message: '', type: 'error')
    ::PluginGuard::Handler.new(self).perform(message, type)
  end
end

require_relative 'plugin_guard/error'
require_relative 'plugin_guard/handler'
require_relative 'plugin_guard/log'
require_relative 'plugin_guard/logs'
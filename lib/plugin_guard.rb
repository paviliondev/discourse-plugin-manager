# frozen_string_literal: true

class ::PluginGuard
  NAMESPACE ||= 'plugin-guard'
  
  attr_reader :file,
              :metadata,
              :sha,
              :branch,
              :handler,
              :directory

  def initialize(directory)
    return false unless File.exists?("#{directory}/plugin.rb")

    @file = File.read("#{directory}/plugin.rb")
    @metadata = ::Plugin::Metadata.parse(file)
    plugin_name = @metadata.name
    return false if ::Plugin::Metadata::OFFICIAL_PLUGINS.include?(plugin_name)
    
    @directory = directory
    Dir.chdir(directory) do
      @sha = Discourse.try_git('git rev-parse HEAD', nil)
      @branch = Discourse.try_git("git branch | sed -n '/\* /s///p'", 'tests-passed')
    end

    @handler = ::PluginGuard::Handler.new(plugin_name, directory)
  end

  def present?
    handler.present?
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

  def handle(message: '', backtrace: '')
    @handler.perform(
      message,
      backtrace,
      precompiled_assets
    )
  end
end
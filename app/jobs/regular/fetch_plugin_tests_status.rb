module Jobs
  class FetchPluginTestsStatus < ::Jobs::Base
    def execute(args)
      ::PluginManager::Plugin.with_attr('tests_host').each do |plugin|
        test_manager = PluginManager::TestManager.new(plugin.tests_host)
        
        if test_manager.ready?
          lastest_build = PluginManager::TestManager.lastest_build(plugin.name)
          
        end
      end
    end
  end
end
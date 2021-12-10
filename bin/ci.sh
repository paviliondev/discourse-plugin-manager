mkdir -p ${env.env.DISCOURSE_ROOT}/lib/plugin_guard
mkdir -p ${env.DISCOURSE_ROOT}/lib/plugin_guard/extensions
mkdir -p ${env.DISCOURSE_ROOT}/lib/plugin_manager
mkdir -p ${env.DISCOURSE_ROOT}/lib/plugin_manager/test_host
mkdir -p ${env.DISCOURSE_ROOT}/lib/plugin_manager/repository_host
mkdir -p ${env.DISCOURSE_ROOT}/plugins_incompatible

ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager_store.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager_store.rb

ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard/extensions/discourse.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard/extensions/discourse.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard/extensions/plugin_instance.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard/extensions/plugin_instance.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard/error.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard/error.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard/handler.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard/handler.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_guard/log.rb ${env.DISCOURSE_ROOT}/lib/plugin_guard/log.rb

ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/discourse.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/discourse.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/manifest.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/manifest.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/notifier.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/notifier.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/plugin.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/plugin.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/test_host.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host/github.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/test_host/github.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_manager.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/test_manager.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/update.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/update.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_owner.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/repository_owner.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/repository_host.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host/github.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/repository_host/github.rb
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_manager.rb ${env.DISCOURSE_ROOT}/lib/plugin_manager/repository_manager.rb

ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/tasks/plugin_guard.rake ${env.DISCOURSE_ROOT}/lib/tasks/plugin_guard.rake
ln -sf ${env.PLUGIN_MANAGER_ROOT}/lib/plugin_initialization_guard.rb ${env.DISCOURSE_ROOT}/lib/plugin_initialization_guard.rb
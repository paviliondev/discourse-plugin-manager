mkdir -p ${DISCOURSE_ROOT}/lib/plugin_guard
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_guard/extensions
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager/test_host
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host
mkdir -p ${DISCOURSE_ROOT}/plugins_incompatible

ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard.rb ${DISCOURSE_ROOT}/lib/plugin_guard.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard/extensions/discourse.rb ${DISCOURSE_ROOT}/lib/plugin_guard/extensions/discourse.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard/extensions/plugin_instance.rb ${DISCOURSE_ROOT}/lib/plugin_guard/extensions/plugin_instance.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard/error.rb ${DISCOURSE_ROOT}/lib/plugin_guard/error.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard/handler.rb ${DISCOURSE_ROOT}/lib/plugin_guard/handler.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_guard/log.rb ${DISCOURSE_ROOT}/lib/plugin_guard/log.rb

ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/discourse.rb ${DISCOURSE_ROOT}/lib/plugin_manager/discourse.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/manifest.rb ${DISCOURSE_ROOT}/lib/plugin_manager/manifest.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/notifier.rb ${DISCOURSE_ROOT}/lib/plugin_manager/notifier.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/plugin.rb ${DISCOURSE_ROOT}/lib/plugin_manager/plugin.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_host.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host/github.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_host/github.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_manager.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/update.rb ${DISCOURSE_ROOT}/lib/plugin_manager/update.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_owner.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_owner.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host/github.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host/github.rb
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_manager.rb

ln -s ${PLUGIN_MANAGER_ROOT}/lib/tasks/plugin_guard.rake ${DISCOURSE_ROOT}/lib/tasks/plugin_guard.rake
ln -s ${PLUGIN_MANAGER_ROOT}/lib/plugin_initialization_guard.rb ${DISCOURSE_ROOT}/lib/plugin_initialization_guard.rb

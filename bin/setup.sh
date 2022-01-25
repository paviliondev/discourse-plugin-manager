mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager/test_host
mkdir -p ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host

ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager_store.rb ${DISCOURSE_ROOT}/lib/plugin_manager_store.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/log.rb ${DISCOURSE_ROOT}/lib/plugin_manager/log.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/discourse.rb ${DISCOURSE_ROOT}/lib/plugin_manager/discourse.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/manifest.rb ${DISCOURSE_ROOT}/lib/plugin_manager/manifest.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/notifier.rb ${DISCOURSE_ROOT}/lib/plugin_manager/notifier.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/plugin.rb ${DISCOURSE_ROOT}/lib/plugin_manager/plugin.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_host.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_host/github.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_host/github.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/test_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager/test_manager.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_owner.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_owner.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_host/github.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_host/github.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/repository_manager.rb ${DISCOURSE_ROOT}/lib/plugin_manager/repository_manager.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/status_handler.rb ${DISCOURSE_ROOT}/lib/plugin_manager/status_handler.rb
ln -sf ${PLUGIN_MANAGER_ROOT}/lib/plugin_manager/user_plugin.rb ${DISCOURSE_ROOT}/lib/plugin_manager/user_plugin.rb

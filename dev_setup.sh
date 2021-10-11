mv -f ${DISCOURSE_ROOT}/lib/plugin_initialization_guard.rb lib/plugin_initialization_guard_old.rb
mkdir -p lib/plugin_guard
mkdir -p lib/plugin_guard/extensions
mkdir -p lib/plugin_manager
mkdir -p lib/plugin_manager/test_host
mkdir -p lib/plugin_manager/repository_host

cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard/extensions/discourse.rb lib/plugin_guard/extensions/discourse.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard/extensions/plugin_instance.rb lib/plugin_guard/extensions/plugin_instance.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard/error.rb lib/plugin_guard/error.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard/handler.rb lib/plugin_guard/handler.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard/log.rb lib/plugin_guard/log.rb

cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager.rb lib/plugin_manager.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/discourse.rb lib/plugin_manager/discourse.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/manifest.rb lib/plugin_manager/manifest.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/notifier.rb lib/plugin_manager/notifier.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/plugin.rb lib/plugin_manager/plugin.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/test_host.rb lib/plugin_manager/test_host.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/test_host/github.rb lib/plugin_manager/test_host/github.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/test_manager.rb lib/plugin_manager/test_manager.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/update.rb lib/plugin_manager/update.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/repository_owner.rb lib/plugin_manager/repository_owner.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/repository_host.rb lib/plugin_manager/repository_host.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/repository_host/github.rb lib/plugin_manager/repository_host/github.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager/repository_manager.rb lib/plugin_manager/repository_manager.rb

cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_guard.rb lib/plugin_guard.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_manager.rb lib/plugin_manager.rb
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/tasks/plugin_guard.rake lib/tasks/plugin_guard.rake
cp -rf ${CODE_ROOT}/discourse-plugin-manager-server/lib/plugin_initialization_guard.rb lib/plugin_initialization_guard.rb
mkdir -p plugins_incompatible

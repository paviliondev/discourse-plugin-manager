mv -f lib/plugin_initialization_guard.rb lib/plugin_initialization_guard_old.rb
mkdir -p lib/plugin_guard
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_guard/error.rb lib/plugin_guard/error.rb
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_guard/handler.rb lib/plugin_guard/handler.rb
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_guard/log.rb lib/plugin_guard/log.rb
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_guard/logs.rb lib/plugin_guard/logs.rb
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_guard.rb lib/plugin_guard.rb
cp -rf ~/code/discourse-plugin-manager-server/lib/tasks/plugin_guard.rake lib/tasks/plugin_guard.rake
cp -rf ~/code/discourse-plugin-manager-server/lib/plugin_initialization_guard.rb lib/plugin_initialization_guard.rb
mkdir -p plugins_incompatible

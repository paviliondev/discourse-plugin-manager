rm -f lib/plugin_guard.rb
rm -f lib/plugin_manager.rb
rm -rf lib/plugin_guard
rm -rf lib/plugin_manager
rm -f lib/tasks/plugin_guard.rake
mv -f lib/plugin_initialization_guard_old.rb lib/plugin_initialization_guard.rb
rm -rf plugins_incompatible

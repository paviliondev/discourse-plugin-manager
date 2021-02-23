rm -f lib/plugin_guard/error.rb
rm -f lib/plugin_guard/handler.rb
rm -f lib/plugin_guard/log.rb
rm -f lib/plugin_guard/logs.rb
rm -f lib/plugin_guard.rb
rm -rf lib/plugin_guard
rm -f lib/tasks/plugin_guard.rake
mv -f lib/plugin_initialization_guard_old.rb lib/plugin_initialization_guard.rb
rm -rf plugins_incompatible

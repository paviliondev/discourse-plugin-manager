CodeRoot="${CODE_ROOT:-/home/$USER/code}"
DiscourseRoot="${DISCOURSE_ROOT:-/home/$USER/discourse}"

cp -rf lib/plugin_guard/error.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_guard/error.rb
cp -rf lib/plugin_guard/handler.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_guard/handler.rb
cp -rf lib/plugin_guard/log.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_guard/log.rb
cp -rf lib/plugin_guard/logs.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_guard/logs.rb
cp -rf lib/plugin_guard.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_guard.rb 
cp -rf lib/tasks/plugin_guard.rake ${CodeRoot}/discourse-plugin-manager-server/lib/tasks/plugin_guard.rake 
cp -rf lib/plugin_initialization_guard.rb ${CodeRoot}/discourse-plugin-manager-server/lib/plugin_initialization_guard.rb 

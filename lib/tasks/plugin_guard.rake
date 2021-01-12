require_relative '../plugin_guard'

task 'assets:precompile:before' do
  ### Ensure all assets added to precompilation by plugins exist. 
  ### If they don't, remove them from precompilation and move the plugin to incompatible directory.
  
  path = "#{Rails.root}/plugins"
  
  Dir.each_child(path) do |folder|
    if guard = PluginGuard.new("#{path}/#{folder}")
      begin
        guard.precompiled_assets.each do |filename|
          pre_path = "#{guard.path}/assets/javascripts/#{filename}"
          
          unless File.exists?(pre_path)
            ## This will not prevent Discourse from working so we only warn
            guard.handle(
              message:"Asset path #{pre_path} does not exist.",
              type: 'warn'
            )
            next
          end

          File.read(pre_path).each_line do |line|
            if line.start_with?("//=")
              directive_parts = line.split(' ')
              directive_path = directive_parts.last.split('.')[0]
              directive = directive_parts[1]
              
              asset_path = ''
              vendor_asset_path = ''

              if directive === 'require'
                asset_path = "#{Rails.root}/app/assets/javascripts/#{directive_path}"
                vendor_asset_path = "#{Rails.root}/vendor/assets/javascripts/#{directive_path}"
              elsif directive === 'require_tree'
                asset_path = "#{guard.path}/assets/javascripts/#{directive_path[2..-1]}"
              end

              unless Dir.glob("#{asset_path}.*").any? || Dir.glob("#{vendor_asset_path}.*").any?
                raise PluginGuard::Error.new, "Sprockets directive #{asset_path} does not exist."
              end
            end
          end
        end
      rescue PluginGuard::Error => error
        guard.handle(message: error.message)
      end
    end
  end
end
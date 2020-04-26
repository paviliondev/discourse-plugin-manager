# name: discourse-server-status
# about: Display public information about server status
# version: 0.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-server-status

register_asset "stylesheets/common/server-status.scss"
register_asset "stylesheets/mobile/server-status.scss", :mobile

if respond_to?(:register_svg_icon)
  register_svg_icon "bug"
end

after_initialize do
  module ::DiscourseServerStatus
    class Engine < ::Rails::Engine
      engine_name 'discourse_server_status'
      isolate_namespace DiscourseServerStatus
    end
  end
  
  ::DiscourseServerStatus::Engine.routes.draw do
    get 'status' => 'status#show'
  end

  ::Discourse::Application.routes.append do
    mount ::DiscourseServerStatus::Engine, at: 'server-status'
  end
  
  class DiscourseServerStatus::UpdateSerializer < ::BasicTopicSerializer
    attributes :event, :url

    def event
      object.event
    end

    def url
      object.url
    end
  end
  
  class DiscourseServerStatus::StatusController < ::ApplicationController
    def show
      render_json_dump(
        update: serialized_update,
        discourse: ::DiscourseUpdates.check_version,
        plugins: DiscourseServerStatus::Plugins.stats
      )
    end
    
    def serialized_update
      if update_topic = DiscourseServerStatus::Update.current
        DiscourseServerStatus::UpdateSerializer.new(update_topic, root: false)
      end
    end
  end
  
  class DiscourseServerStatus::Update
    def self.current
      if SiteSetting.update_category_id &&
        (category = Category.find_by(id: SiteSetting.update_category_id)).present?
        TopicQuery.new(nil, 
          category: category.id,
          limit: 1
        ).list_agenda.topics.first
      end
    end
  end
  
  class DiscourseServerStatus::Plugins
    def self.stats
      @@stats ||= begin
        stats = []
        base_path = "#{Rails.root}/plugins"
        
        Dir.each_child(base_path) do |folder|
          plugin_path = "#{base_path}/#{folder}"
          file = File.read("#{plugin_path}/plugin.rb")
          metadata = Plugin::Metadata.parse(file)
          
          if ::Plugin::Metadata::OFFICIAL_PLUGINS.exclude?(metadata.name)
            sha = nil
            branch = nil
            
            Dir.chdir(plugin_path) do
              sha = `git rev-parse HEAD`.strip
              branch = `git rev-parse --abbrev-ref HEAD`.strip
            end
                      
            stats.push(
              name: metadata.name,
              url: metadata.url,
              installed_sha: sha,
              git_branch: branch,
            )
          end
        end
        
        stats
      end
    end
  end
end
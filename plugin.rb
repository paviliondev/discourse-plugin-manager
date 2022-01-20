# frozen_string_literal: true
# name: discourse-plugin-manager
# about: Pavilion's Plugin Manager
# version: 0.1.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-plugin-manager

register_asset "stylesheets/common/plugin-manager.scss"
register_asset "stylesheets/mobile/plugin-manager.scss", :mobile

register_svg_icon "bug"
register_svg_icon "far-check-circle"
register_svg_icon "far-times-circle"
register_svg_icon "code-branch"
register_svg_icon "vial"
register_svg_icon "building"
register_svg_icon "far-life-ring"
register_svg_icon "far-question-circle"

%w(
  ../lib/plugin_manager.rb
  ../lib/plugin_manager_store.rb
).each do |path|
  load File.expand_path(path, __FILE__)
end

after_initialize do
  PluginManagerStore.commit_cache

  %w(
    ../mailers/plugin_mailer.rb
    ../app/jobs/scheduled/fetch_plugin_tests_status.rb
    ../app/jobs/scheduled/fetch_remote_plugins.rb
    ../app/jobs/regular/send_plugin_notification.rb
    ../app/controllers/plugin_manager/discourse_controller.rb
    ../app/controllers/plugin_manager/plugin_controller.rb
    ../app/controllers/plugin_manager/plugin_status_controller.rb
    ../app/controllers/plugin_manager/plugin_user_controller.rb
    ../app/serializers/plugin_manager/discourse_serializer.rb
    ../app/serializers/plugin_manager/log_serializer.rb
    ../app/serializers/plugin_manager/basic_plugin_serializer.rb
    ../app/serializers/plugin_manager/plugin_serializer.rb
    ../app/serializers/plugin_manager/plugin_user_serializer.rb
    ../app/serializers/plugin_manager/owner_serializer.rb
    ../config/routes.rb
  ).each do |path|
    load File.expand_path(path, __FILE__)
  end

  PluginManager::Plugin.add_extra_metadata

  unless Rails.env.test?
    PluginManager::Manifest.update_local_plugins
    PluginManager::Manifest.update_test_status
  end

  user_key_suffix = 'plugin-registrations'
  user_updated_at_key_suffix = 'plugin-registrations-updated-at'

  class UserPlugin
    include ActiveModel::Serialization

    attr_reader :name,
                :domain

    attr_accessor :updated_at

    def initialize(name, domain)
      @name = name
      @domain = domain
    end
  end

  add_to_class(:user, :plugin_registered?) do |domain, plugin_name|
    key = "#{plugin_name}-#{user_key_suffix}"
    custom_fields[key].present? && custom_fields[key].include?(domain)
  end

  add_to_class(:user, :register_plugins) do |domain, plugin_names|
    plugin_names.select { |n| PluginManager::Plugin.exists?(n) }.each do |name|
      key = "#{name}-#{user_key_suffix}"
      custom_fields[key] ||= []
      custom_fields[key].push(domain) unless custom_fields[key].include?(domain)
    end
    custom_fields["#{domain}-#{user_updated_at_key_suffix}"] = DateTime.now.iso8601(3)

    save_custom_fields(true)
    update_plugin_group_membership(domain)
    registered_plugins(domain)
  end

  add_to_class(:user, :registered_plugins) do |domain = nil|
    query = "user_id = #{self.id} AND name LIKE '%-#{user_key_suffix}'"
    query += " AND value LIKE '%#{domain}%'" if domain

    ::UserCustomField.where(query).map do |ucf|
      UserPlugin.new(ucf.name.split("-#{user_key_suffix}").first, ucf.value)
    end
  end

  add_to_class(:user, :registered_plugins_updated_at) do |domain = nil|
    query = "user_id = #{self.id}"

    if domain
      query += "AND name = '#{domain}-#{user_updated_at_key_suffix}'"
    else
      query += "AND name LIKE '%-#{user_updated_at_key_suffix}'"
    end

    records = ::UserCustomField.where(query)
    return records.first.value if domain.present?

    records.reduce({}) do |result, r|
      domain = r.name.split("-#{user_updated_at_key_suffix}").first
      result[domain] = r.value
      result
    end
  end

  add_to_class(:user, :update_plugin_group_membership) do |domain|
    registered_plugins(domain).each do |plugin_name|
      if plugin = PluginManager::Plugin.get(plugin_name)
        plugin.add_user(self)
      end
    end
  end

  add_user_api_key_scope(:plugin_user,
    methods: :post,
    actions: "plugin_manager/plugin_user#register",
    params: %i[plugin_names domain]
  )

  if defined?(DiscourseCodeReview) == 'constant' && DiscourseCodeReview.class == Module
    DiscourseCodeReview::Hooks.add_parent_category_finder(:plugin_manager) do |repo_name, repo_id, issues|
      if issues && category = Category.find_by(slug: repo_name.split("/", 2).last)
        category.id
      else
        nil
      end
    end

    DiscourseCodeReview::Hooks.add_category_namer(:plugin_manager) do |repo_name, repo_id, issues|
      if issues
        "issues"
      else
        nil
      end 
    end
  end
end

# frozen_string_literal: true
class PluginManager::Notifier

  attr_reader :plugin
  attr_accessor :log

  def initialize(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
  end

  def send(type, log)
    @log = log
    send_post(type) if send_post?
    send_email(type) if send_email?
  end

  def send_email(type)
    Jobs.enqueue(:send_plugin_notification,
      plugin: @plugin.name,
      site: SiteSetting.title,
      contact_emails: contact_emails,
      title: self.class.title(type, @plugin.display_name),
      raw: self.class.email_body(type, @log, @plugin.display_name)
    )
  end

  def send_post(type)
    body = {
      title: self.class.title(type, @plugin.display_name),
      raw: self.class.post_markdown(type, @log, @plugin.display_name),
      archetype: "regular"
    }

    if type === :broken
      body[:tags] = post_tags
      body[:category] = post_category
    elsif type === :fixed
      body[:topic_id] = @log.issue_id
    end

    response = Excon.post("#{post_settings[:base_url]}/posts",
      headers: {
        "Content-Type" => "application/json",
        "Api-Username" => "#{post_settings[:api_user]}",
        "Api-Key" => "#{post_settings[:api_token]}"
      },
      body: body.to_json
    )

    if response.status == 200
      result = nil

      begin
        result = JSON.parse(response.body)
      rescue JSON::ParserError
        #
      end

      if result && result['topic_id']
        @log.issue_id = result['topic_id']
        @log.issue_url = post_settings[:base_url] + "/t/" + result['topic_id'].to_s
        @log.save

        return true
      end
    end

    false
  end

  def self.title(type, plugin_name)
    I18n.t("plugin_manager.notifier.#{type}.title", plugin_name: plugin_name)
  end

  def self.email_body(type, log, plugin_name)
    <<~EOF
      #{I18n.t("plugin_manager.notifier.#{type}.body", plugin_name: plugin_name)}

      Time: #{log.updated_at}
      Message: #{log.message}
      Discourse Branch: #{log.discourse_branch}
      Plugin Branch: #{log.branch}
      #{post_markdown_details(log)}
    EOF
  end

  def self.post_markdown(type, log, plugin_name)
    <<~EOF
      #{I18n.t("plugin_manager.notifier.#{type}.body", plugin_name: plugin_name)}

      Time: #{log.updated_at}
      Message: ``#{log.message}``

      ### Discourse
      Branch: #{log.discourse_branch}

      ### Plugin
      Branch: #{log.branch}

      ### Details
      #{post_markdown_details(log)}
    EOF
  end

  def self.post_markdown_details(log)
    result = ""
    result += "Test url: #{log.test_url}" if log.test_url
    result += "Issue url: #{log.issue_url}" if log.issue_url

    if log.backtrace
      result += <<~EOF
        Backtrace:
        #{log.backtrace}
      EOF
    end
  end

  protected

  def post_settings
    @post_settings ||= begin
      base_url = SiteSetting.plugin_manager_issue_management_site_base_url
      api_user = SiteSetting.plugin_manager_issue_management_site_api_user
      api_token = SiteSetting.plugin_manager_issue_management_site_api_token

      if base_url && api_user && api_token
        {
          base_url: base_url,
          api_user: api_user,
          api_token: api_token
        }
      else
        nil
      end
    end
  end

  def contact_emails
    @plugin.contact_emails.present? ?
    @plugin.contact_emails.split(",").map(&:strip).join(",") :
    ''
  end

  def send_email?
    contact_emails.present? && !send_post?
  end

  def send_post?
    @plugin.owner&.name&.downcase == 'pavilion' && (
      post_settings[:base_url].present? &&
      post_settings[:api_user].present? &&
      post_settings[:api_token].present?
    )
  end

  def post_category
    SiteSetting.plugin_manager_issue_management_site_issue_category_id
  end

  def post_tags
    tags = SiteSetting.plugin_manager_issue_management_site_issue_tags.split('|')
    tags << @plugin.name.sub("discourse-", "")
    tags
  end
end

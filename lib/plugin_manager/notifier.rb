class PluginManager::Notifier

  attr_reader :plugin,
              :log

  def initialize(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
    @log = ::PluginGuard::Log.list(@plugin.name).first
  end

  def send
    return unless @plugin && @log

    if send_post?
      send_post
    elsif send_email?
      send_email
    else
      false
    end
  end

  def send_email
    Jobs.enqueue(:send_plugin_incompatible_notification,
      plugin: @plugin.name,
      site: SiteSetting.title,
      contact_emails:  contact_emails,
      title: email_and_post_title,
      raw: email_body
    )
  end

  def send_post
    body = {
      title: email_and_post_title,
      raw: post_markdown,
      tags: post_tags,
      category: post_category,
      archetype: "regular"
    }

    response = Excon.post("#{post_settings[:base_url]}/posts",
      :headers => {
        "Content-Type" => "application/json",
        "Api-Username" => "#{post_settings[:api_user]}",
        "Api-Key" => "#{post_settings[:api_token]}"
      },
      :body => body
    )

    response_body = JSON.parse(response.body)
    @log.issue_url = response_body['topic']['url']
    @log.save
  end

  def email_and_post_title
    I18n.t('plugin_manager.notifier.incompatible.title', plugin_name: @plugin.name)
  end

  def email_body
    <<~EOF
      #{@plugin.name} encountered an error.

      Time: #{@log.date}
      Message: #{@log.message}
      Discourse Commit: #{@log.discourse_sha}
      Discourse Branch: #{@log.discourse_branch}
      Plugin Commit: #{@log.plugin_sha}
      Plugin Branch: #{@log.plugin_branch}
      #{extra}
    EOF
  end

  def post_markdown
    <<~EOF
      #{@plugin.name} encountered an error.

      Time: #{@log.date}
      Message: ``#{@log.message}``

      ### Discourse
      Commit: #{@log.discourse_sha}
      Branch: #{@log.discourse_branch}

      ### Plugin
      Commit: #{@log.plugin_sha}
      Branch: #{@log.plugin_branch}

      ### Details
      #{extra}
    EOF
  end

  def extra
    extra = ""
    extra += "Test url: #{@log.test_url}" if @log.test_url
    extra += "Issue url: #{@log.issue_url}" if @log.issue_url

    if @log.backtrace
      extra += <<~EOF
        Backtrace:
        #{@log.backtrace}
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
    contact_emails.present?
  end

  def send_post?
    contact_emails&.include?("thepavilion.io") && post_settings.present?
  end

  def post_category
    SiteSetting.plugin_manager_issue_management_site_issue_category_id
  end

  def post_tags
    tags = SiteSetting.plugin_manager_issue_management_site_issue_tags.split('|')
    tags << @plugin.name
    tags
  end
end
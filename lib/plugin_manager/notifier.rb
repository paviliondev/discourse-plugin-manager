# frozen_string_literal: true
class PluginManager::Notifier

  attr_reader :plugin
  attr_accessor :log

  def initialize(plugin_name)
    @plugin = ::PluginManager::Plugin.get(plugin_name)
  end

  def send(type, log)
    @log = log
    @type = type
    send_post if send_post?
    send_email if send_email?
  end

  def send_email
    Jobs.enqueue(:send_plugin_notification,
      plugin: @plugin.name,
      site: SiteSetting.title,
      contact_emails: contact_emails,
      title: self.class.title(@type, @log, @plugin.display_name),
      raw: self.class.email_body(@type, @log, @plugin.display_name)
    )
  end

  def send_post
    opts = {
      raw: self.class.post_markdown(@type, @log, @plugin.display_name)
    }

    if @type === :broken
      category_id = @plugin.category_id
      local_management = SiteSetting.plugin_manager_issues_local
      subcategory_name = SiteSetting.plugin_manager_issues_local_subcategory_name

      if local_management && subcategory_name.present?
        category = Category.find_by(parent_category_id: @plugin.category_id, name: subcategory_name)
        category_id = category.id if category
      end

      opts.merge!(
        title: self.class.title(@type, @log, @plugin.display_name),
        archetype: "regular",
        category: category_id,
        tags: post_tags
      )
    end

    if @type === :fixed
      opts.merge!(
        topic_id: @log.issue_id
      )
    end

    if SiteSetting.plugin_manager_issues_local
      local_post(opts)
    else
      remote_post(opts)
    end
  end

  def local_post(opts)
    opts = opts.merge(skip_validations: true)
    creator = PostCreator.new(Discourse.system_user, opts)
    post = creator.create
    topic = post.topic

    if @type === :fixed
      topic.update_status('closed', true, Discourse.system_user)
    end

    if @type === :broken
      update_log(topic.id, topic.url)
    end
  end

  def remote_post(opts)
    response = Excon.post("#{post_settings[:base_url]}/posts",
      headers: {
        "Content-Type" => "application/json",
        "Api-Username" => "#{post_settings[:api_user]}",
        "Api-Key" => "#{post_settings[:api_token]}"
      },
      body: opts.to_json
    )

    return false unless response.status == 200
    result = nil

    begin
      result = JSON.parse(response.body)
    rescue JSON::ParserError
      return false
    end

    return false unless result && result['topic_id']

    update_log(result['topic_id'], post_settings[:base_url] + "/t/" + result['topic_id'].to_s)
  end

  def update_log(topic_id, url)
    @log.issue_id = topic_id
    @log.issue_url = url
    @log.save
  end

  def self.title(type, log, plugin_name)
    I18n.t("plugin_manager.notifier.#{type.to_s}.title",
      plugin_name: plugin_name,
      discourse_branch: log.discourse_branch,
      plugin_branch: log.branch
    )
  end

  def self.email_body(type, log, plugin_name)
    <<~EOF
      #{I18n.t("plugin_manager.notifier.#{type.to_s}.body", plugin_name: plugin_name)}

      Time: #{log.updated_at}
      Message: #{log.message}
      Discourse Branch: #{log.discourse_branch}
      Discourse SHA: #{log.discourse_sha}
      Plugin Branch: #{log.branch}
      Plugin SHA: #{log.sha}
      #{post_markdown_details(log)}
    EOF
  end

  def self.post_markdown(type, log, plugin_name)
    body = I18n.t("plugin_manager.notifier.#{type.to_s}.body", plugin_name: plugin_name)

    if type === :fixed
      body
    else
      <<~EOF
        #{body}

        Time: #{log.updated_at}
        Message: ``#{log.message}``

        ### Discourse
        Branch: #{log.discourse_branch}
        SHA: #{log.discourse_sha}

        ### Plugin
        Branch: #{log.branch}
        SHA: #{log.sha}

        ### Details
        #{post_markdown_details(log)}
      EOF
    end
  end

  def self.post_markdown_details(log)
    result = ""
    result += "Test url: #{log.test_url}\n" if log.test_url

    if !SiteSetting.plugin_manager_issues_local && log.issue_url
      result += "Issue url: #{log.issue_url}\n"
    end

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
      base_url = SiteSetting.plugin_manager_issues_site_base_url
      api_user = SiteSetting.plugin_manager_issues_site_api_user
      api_token = SiteSetting.plugin_manager_issues_site_api_token

      if base_url.present? && api_user.present? && api_token.present?
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
    SiteSetting.plugin_manager_issues_local || post_settings.present?
  end

  def post_tags
    tags = SiteSetting.plugin_manager_issues_site_issue_tags.split('|')
    tags << @plugin.name.sub("discourse-", "")
    tags << @log.branch
    tags
  end
end

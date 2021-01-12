class ::PluginManager::TestManager
  attr_accessor :domain, :token
  
  def initialize(host_name)
    host = PluginManager::TestHosts.get(host_name)
    return unless host
    
    @domain = host.domain
    
    host_tokens = SiteSetting.plugin_manager_test_host_tokens.split('|')
    host_tokens.each do |ht|
      parts = ht.split(':')      
      if parts.first.to_sym == host.to_sym
        @token = parts.last.to_s
      end
    end
  end
  
  def ready?
    @domain.present? && @token.present?
  end
  
  def lastest_build(plugin_name)
    plugin = ::PluginManager::Plugin.get(plugin_name)
    return nil unless plugin && plugin.url
    request("/repo/#{URI(plugin.url).path}/branch/#{Discourse.git_branch}")
  end
  
  def request(endpoint, opts={})
    url = URI("https://#{@domain}#{endpoint}")
    url.query = URI.encode_www_form(opts[:query]) if opts[:query].present?
        
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    content_type = opts[:content_type] || 'application/x-www-form-urlencoded'
    
    request_class = opts[:class] || Net::HTTP::Get
    request = request_class.new url
    request.body = URI.encode_www_form(opts[:body]) if opts[:body].present?
    request["content-type"] = content_type
    request["Authorization"] = "token #{@token}"
        
    response = http.request(request)
            
    if response.kind_of? Net::HTTPSuccess
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { error: "request failed"}
      end
    else
      { error: "request failed" }
    end
  end
end
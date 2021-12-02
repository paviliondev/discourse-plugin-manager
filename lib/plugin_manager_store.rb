class PluginManagerStore
  @cache = {}

  def self.set(namespace, key, value)
    if plugin_store_ready?
      PluginStore.set(namespace, key, value)
    else
      @cache[namespace] ||= {}
      @cache[namespace][key] = value
    end
  end

  def self.get(namespace, key)
    if plugin_store_ready?
      PluginStore.get(namespace, key)
    else
      @cache.dig(namespace, key)
    end
  end

  def self.commit_cache
    @cache.each do |namespace, values|
      values.each do |key, value|
        PluginStore.set(namespace, key, value)
      end
    end
    @cache = {}
  end

  def self.plugin_store_ready?
    database_connected? && defined?(PluginStore)
  end

  def self.database_connected?
    ActiveRecord::Base.connection
  rescue ActiveRecord::ConnectionNotEstablished
    false
  else
    true
  end
end
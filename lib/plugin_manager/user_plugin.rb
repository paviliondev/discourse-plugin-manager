# frozen_string_literal: true

class PluginManager::UserPlugin
  include ActiveModel::Serialization

  attr_reader :name,
              :domain

  attr_accessor :updated_at

  def initialize(name, domain)
    @name = name
    @domain = domain
  end
end

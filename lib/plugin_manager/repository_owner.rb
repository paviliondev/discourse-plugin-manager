# frozen_string_literal: true
class ::PluginManager::RepositoryOwner
  include ActiveModel::Serialization

  attr_reader :name,
              :url,
              :email,
              :website,
              :avatar_url,
              :description

  attr_accessor :type

  def initialize(attrs)
    @name = attrs[:name]
    @url = attrs[:url]
    @email = attrs[:email]
    @website = attrs[:website]
    @avatar_url = attrs[:avatar_url]
    @description = attrs[:description]
    @type = attrs[:type]
  end

  def self.types
    @types ||= ::Enum.new(
      user: 0,
      organization: 1
    )
  end
end

class DiscourseServerStatus::UpdateSerializer < ::BasicTopicSerializer
  attributes :event, :url

  def event
    object.event
  end

  def url
    object.url
  end
end
::DiscourseServerStatus::Engine.routes.draw do
  get 'status' => 'status#show'
end

::Discourse::Application.routes.append do
  mount ::DiscourseServerStatus::Engine, at: 'server-status'
end
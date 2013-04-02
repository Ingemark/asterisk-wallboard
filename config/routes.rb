WallboardSystem::Application.routes.draw do

  root :to => redirect("/users/sign_in") # Make Sign In home page

  devise_for :users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match "/agent" => "agent#index"
  match "/manager" => "manager#index"
  match "/manager/agent-logoff/:agent_id/:queue" => "manager#agent_logoff", :as => "manager_agent_logoff"
  match "/agent/logon/:queue_id" => "agent#logon", :as => "agent_logon"
  match "/agent/logoff/:queue_id" => "agent#logoff", :as => "agent_logoff"
end

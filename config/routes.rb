WallboardSystem::Application.routes.draw do

  root :to => redirect("/users/sign_in") # Make Sign In home page

  devise_for :users, :skip => [:registrations]                                          
    as :user do
      get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'    
      put 'users' => 'devise/registrations#update', :as => 'user_registration'
    end
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # Manager routes
  match "/manager" => "manager#index"
  match "/manager/agent-logoff/:agent_id/:queue" => "manager#agent_logoff", :as => "manager_agent_logoff"
  match "/manager/reset-queue-stats/:queue" => "manager#reset_queue_stats", :as => "manager_reset_queue_stats"
  
  # Agent routes
  match "/agent" => "agent#index"
  match "/agent/logon/:queue_id" => "agent#logon", :as => "agent_logon"
  match "/agent/logoff/:queue_id" => "agent#logoff", :as => "agent_logoff"
end

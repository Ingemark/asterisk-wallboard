WallboardSystem::Application.routes.draw do

  root :to => redirect("/users/sign_in") # Make Sign In home page

  devise_for :users
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  match "/agent" => "agent#index"
  match "/manager" => "manager#index"
end

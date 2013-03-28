class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Redirect to role home view if not authorized
  rescue_from CanCan::AccessDenied do |exception|
    if current_user
      redirect_to "/#{current_user.role}", :alert => exception.message
    else
      redirect_to :new_user_session, :alert => exception.message
    end
  end
  
  protected

  def after_sign_in_path_for(resource)
    cookies.delete :pbxis_ticket
    stored_location_for(:user) || "/#{current_user.role}"
  end

  private

  def after_sign_out_path_for(resource)
    cookies.delete :pbxis_ticket
    stored_location_for(:user) || root_path
  end
end

class HomeController < ApplicationController
  def index
    if !current_user
      redirect_to new_user_session_path
    else
      case current_user.role
      when "agent"
        redirect_to agent_index_path
      when "manager"
        redirect_to manager_index_path
      else
        render :status => :forbidden, :text => "Forbidden page"
      end
    end
  end
  
  def refresh_stats
    if current_user.role == "agent"
      redirect_to agent_refresh_stats_path
    elsif current_user.role == "manager"
      redirect_to manager_refresh_stats_path
    else
      render :nothing => true 
    end
  end
end

class HomeController < ApplicationController
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

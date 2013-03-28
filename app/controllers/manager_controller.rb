class ManagerController < ApplicationController
  authorize_resource :class => false
  
  def index
    @queues = PbxQueue.all

    params = {
      :queues => @queues.map { |q| q.name },
      :agents => User.select("agent_id").map { |a| a.agent_id }
    }

    if !@queues.empty? && !cookies.has_key?(:pbx_ticket)
      begin
        cookies[:pbxis_ticket] = RestClient.post("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/ticket", params.to_json).to_str.gsub('"', '')
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    respond_to do |format|
      format.html
    end
  end
end

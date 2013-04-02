class AgentController < ApplicationController
  authorize_resource :class => false
  
  # Action renders agent's home view with all the queues he has permission 
  # to monitor together with actions he's allowed to do on those queues.
  def index
    @queues = current_user.pbx_queues

    
    # Get PBXIS ticket
    if !@queues.empty? && !cookies.has_key?(:pbxis_ticket)
      
      pbxis_params = {
        :queues => @queues.map { |q| q.name },
        :agents => [current_user.extension]
      }
      
      begin
        cookies[:pbxis_ticket] = RestClient.post("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/ticket", 
          pbxis_params.to_json, :content_type => :json).to_str.gsub('"', '')
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    # Get initial queue status
    begin
        @queue_statuses = {}
        @queues.each do |queue|
          @queue_statuses[queue.name] = ActiveSupport::JSON.decode(
            RestClient.get("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/queue/status?queue=#{queue.name}"))[0]
          @queue_statuses[queue.name]["members"].delete_if { |m| m["memberName"] != current_user.extension }
        end
    rescue => e
      flash[:alert] = "An error occurred while trying to retrieve queue status: #{e.message}"
    end
    
    respond_to do |format|
      format.html
    end
  end
  
  # Action logs current user on the specified queue.
  def logon
    require "pbxis_functions"
    begin
      @pbxis_result = PbxisFunctions.log_on_off current_user, params[:queue_id], :add
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  # Action logs current user off the specified queue.
  def logoff
    require "pbxis_functions"
    begin
      @pbxis_result = PbxisFunctions.log_on_off current_user, params[:queue_id], :remove
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
end

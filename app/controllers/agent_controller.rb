class AgentController < ApplicationController
  authorize_resource :class => false
  
  # Action renders agent's home view with all the queues he has permission 
  # to monitor together with actions he's allowed to do on those queues.
  def index
    require 'pbxis'
    @queues = current_user.pbx_queues

    
    # Get ticket
    if !@queues.empty? && !cookies.has_key?(:pbxis_ticket)
      
      begin
        queues = @queues.map { |q| q.name }
        agents = [current_user.extension]
        cookies[:pbxis_ticket] = Pbxis::PbxisWS.get_ticket queues, agents
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    # Get initial queue status
    begin
        @queue_statuses = {}
        @queues.each do |queue|
          @queue_statuses[queue.name] = Pbxis::PbxisWS.get_status queue.name
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
    require "pbxis"
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = Pbxis::PbxisWS.log_on agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  # Action logs current user off the specified queue.
  def logoff
    require "pbxis"
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = Pbxis::PbxisWS.log_off agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
end

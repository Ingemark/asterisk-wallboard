class ManagerController < ApplicationController
  authorize_resource :class => false
  
  def index
    require 'pbxis'
    
    @queues = PbxQueue.order "name"
    @agents = User.where(:role => "agent").order "extension"

    if !@queues.empty? && !cookies.has_key?(:pbxis_ticket)
      begin
        cookies[:pbxis_ticket] = Pbxis::PbxisWS.get_ticket(@queues.map { |q| q.name }, @agents.map { |a| a.extension })
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    # Get initial queue statuses
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
  
  def agent_logoff
    require "pbxis"
    begin
      PbxQueue.where(:name => params[:queue])[0]
      agent = User.find(params[:agent_id])
      Pbxis::PbxisWS.log_off agent.extension, queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def reset_queue_stats
    require "pbxis"
    begin
      queue = PbxQueue.where(:name => params[:queue])[0]
      Pbxis::PbxisWS.reset_queue_stats queue.name
      @queue_status = Pbxis::PbxisWS.get_status queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
end

class ManagerController < ApplicationController
  authorize_resource :class => false
  
  def initialize
    require 'pbxis'
    @pbxis_ws = Pbxis::PbxisWSCached.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
    super
  end
  
  def index
    
    @queues = PbxQueue.order "name"
    @agents = User.where(:role => "agent").order "extension"

    # Aquire ticket
    if !@queues.empty? && !cookies.has_key?(:pbxis_ticket)
      begin
        agents = @agents.map { |a| a.extension }
        if current_user.extension
          agents << current_user.extension
        end
        cookies[:pbxis_ticket] = @pbxis_ws.get_ticket(@queues.map { |q| q.name }, agents)
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    # Get initial queue statuses
    begin
        @queue_statuses = {}
        @queues.each do |queue|
          @queue_statuses[queue.name] = Rails.cache.fetch(queue.name) do
            @pbxis_ws.get_status queue.name
          end
        end
    rescue => e
      flash[:alert] = "An error occurred while trying to retrieve queue status: #{e.message}"
    end
 
    respond_to do |format|
      format.html
    end
  end
  
  # Action loggs agent off the queue
  def agent_logoff
    begin
      queue = PbxQueue.where(:name => params[:queue])[0]
      agent = User.find(params[:agent_id])
      @pbxis_ws.log_off agent.extension, queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  # Action resets queue statistics and updates the view with new statistics
  def reset_queue_stats
    begin
      queue = PbxQueue.where(:name => params[:queue])[0]
      @pbxis_ws.reset_queue_stats queue.name
      @queue_status = @pbxis_ws.get_status queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_stats
    begin
      queues = PbxQueue.order "name"
      @queue_statuses = {}
      queues.each do |queue|
        @queue_statuses[queue.name] = Rails.cache.fetch(queue.name) do
          @pbxis_ws.get_status queue.name
        end
      end
    rescue => e
      flash[:alert] = e.message
    end

    respond_to do |format|
      format.js
    end
  end
  
end

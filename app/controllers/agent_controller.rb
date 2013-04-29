class AgentController < ApplicationController
  authorize_resource :class => false
  
  def initialize
    require 'pbxis'
    @pbxis_ws = Pbxis::PbxisWSCached.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
    super
  end
  
  # Action renders agent's home view with all the queues he has permission 
  # to monitor together with actions he's allowed to do on those queues.
  def index
    all_queues = current_user.pbx_queues # all queues
    invalid_queues = []
    @queues = [] # valid queues
    
    # Get initial queue status
    begin
      @queue_statuses = {}
      all_queues.each do |queue|
        
        # Need to use non cached PbxisWS to get most up-to-date status to show on index page
        pbxis_ws = Pbxis::PbxisWS.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
        status = pbxis_ws.get_status queue.name
        
        if status != nil
          @queue_statuses[queue.name] = status
          @queues << queue
        else
          invalid_queues << queue.name
        end
      end
      
      if !invalid_queues.empty?
        flash[:alert] = "Invalid queues: #{invalid_queues.join(', ')}"
      end
    rescue => e
      flash[:alert] = "An error occurred while trying to retrieve queue statuses: #{e.message}"
    end
    
    
    # Get ticket
    if !@queues.empty?
      
      begin
        agents = [current_user.extension]
        cookies[:pbxis_ticket] = @pbxis_ws.get_ticket(@queues.map { |q| q.name }, agents)
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end

    respond_to do |format|
      format.html
    end
  end
  
  # Action logs current user on the specified queue.
  def logon
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.log_on agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  # Action logs current user off the specified queue.
  def logoff
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.log_off agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def pause
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.pause_agent agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def unpause
    begin
      agent = current_user.extension
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.unpause_agent agent, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def refresh_stats
    begin
      queues = current_user.pbx_queues
      @queue_statuses = {}
      queues.each do |queue|
        @queue_statuses[queue.name] = @pbxis_ws.get_status queue.name
      end
    rescue => e
      flash[:alert] = e.message
    end

    respond_to do |format|
      format.js
    end
  end
  
  def edit_ext
    @user = current_user
    respond_to do |format|
      format.html { render :template => 'shared/_edit_ext.html.erb', :layout => 'devise' }
    end
  end
  
  def update_ext
    pbxis_ws = Pbxis::PbxisWS.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
    @user = current_user
    new_ext = params[:user][:extension]
    old_ext = @user.extension
    
    # Update extension
    if !@user.update_attributes(:extension => new_ext)
      flash[:alert] = "Extension already exists"
      
      respond_to do |format|
        format.html { render :template => 'shared/_edit_ext.html.erb', :layout => 'devise' }
      end
    else
      # Re-logon agent to all queues he was logged on before
      if old_ext != new_ext
        @user.pbx_queues.each do |queue|
          
            status = pbxis_ws.get_status queue.name
            
            if status["members"].has_key? old_ext.to_s
              res = pbxis_ws.log_off old_ext.to_s, queue.name
              puts "Result: #{res}"
              
              if !new_ext.empty?
                pbxis_ws.log_on new_ext.to_s, queue.name
                if status["members"][old_ext]["paused"] == true
                  pbxis_ws.pause_agent new_ext.to_s, queue.name
                end
              end
            end
        end
      end
      
      respond_to do |format|
        format.html { redirect_to :root }
      end
    end
  end
end

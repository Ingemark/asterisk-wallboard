class ManagerController < AgentController
  authorize_resource :class => false
  
  def initialize
    require 'pbxis'
    @pbxis_ws = Pbxis::PbxisWSCached.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
    super
  end
  
  def index
    require 'set'
    
    pbxis_ws = Pbxis::PbxisWS.new(Settings.pbxisws["host"], Settings.pbxisws["port"])
    @agents = User.where(:role => ["agent", "manager"]).where("extension <> ''").order "extension" # all agents and managers with extension number
    all_queues = PbxQueue.order "name" # all queues
    invalid_queues = []
    @queues = [] # valid queues
    @loggedon_agents = Set.new
    
    # Get initial queue status
    begin
      @queue_statuses = {}
      all_queues.each do |queue|
        status = pbxis_ws.get_status queue.name
        
        if status != nil
          @queue_statuses[queue.name] = status
          @queues << queue
          
          # Add agent to the loggedon_agents set
          status["members"].keys.each do |member|
            agent = User.where(:extension => member)
            @loggedon_agents.add member if !agent.empty?
          end
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
        cookies[:pbxis_ticket] = pbxis_ws.get_ticket(@queues.map { |q| q.name }, @agents.map { |a| a.extension })
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
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
        @queue_statuses[queue.name] = @pbxis_ws.get_status queue.name
      end
    rescue => e
      flash[:alert] = e.message
    end

    respond_to do |format|
      format.js
    end
  end
  
  def pause_agent
    begin
      agent = User.find(params[:agent_id])
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.pause_agent agent.extension, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
  
  def unpause_agent
    begin
      agent = User.find(params[:agent_id])
      @queue = PbxQueue.find(params[:queue_id])
      @pbxis_result = @pbxis_ws.unpause_agent agent.extension, @queue.name
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
end

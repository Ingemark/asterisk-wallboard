class ManagerController < ApplicationController
  authorize_resource :class => false
  
  def index
    queues = PbxQueue.order "name"
    @agents = User.where(:role => "agent").order "extension"

    pbxis_params = {
      :queues => queues.map { |q| q.name },
      :agents => User.select("extension").map { |a| a.extension }
    }

    if !queues.empty? && !cookies.has_key?(:pbxis_ticket)
      begin
        cookies[:pbxis_ticket] = RestClient.post("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/ticket", 
          pbxis_params.to_json, :content_type => :json).to_str.gsub('"', '')
      rescue => e
        flash[:alert] = "An error occurred while trying to retrieve PBXIS ticket: #{e.message}"
      end
    end
    
    # Get initial queue statuses
    begin
        @queue_statuses = []
        
        queues.each do |queue|
          @queue_statuses << ActiveSupport::JSON.decode(RestClient.get("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/queue/status?queue=#{queue.name}"))[0]
        end
    rescue => e
      flash[:alert] = "An error occurred while trying to retrieve queue status: #{e.message}"
    end
 
    respond_to do |format|
      format.html
    end
  end
  
  def agent_logoff
    require "pbxis_functions"
    begin
      queue = PbxQueue.where(:name => params[:queue])[0]
      user = User.find(params[:agent_id])
      @pbxis_result = PbxisFunctions.log_on_off user, queue.id, :remove
    rescue => e
      flash[:alert] = e.message
    end
    
    respond_to do |format|
      format.js
    end
  end
end

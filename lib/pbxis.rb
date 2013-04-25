# Module provides API for pbxis-ws.
module Pbxis
  
  # Class implements API to pbxis-ws.
  class PbxisWS
    
    # Initializer sets pbxis-ws host and port received as arguments.
    def initialize(host, port)
      @host_addr = "http://#{host}:#{port}"
    end

    # Method gets ticket for given queues and agents. Ticket is a string.
    def get_ticket(queues, agents)
      params = {
        :queues => queues,
        :agents => agents
      }
      RestClient.post("#{@host_addr}/ticket", params.to_json, :content_type => :json).to_str.gsub('"', '')
    end
    
    # Method logs agent on the queue
    def log_on(agent, queue)
      params = {
        :queue => queue,
        :agent => agent
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{@host_addr}/queue/add", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to log agent on: #{e.message}"
      end
    end
    
    # Method logs agent off the queue
    def log_off(agent, queue)
      params = {
        :queue => queue,
        :agent => agent
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{@host_addr}/queue/remove", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to log agent on: #{e.message}"
      end
    end
    
    # Method fetches queue status, i.e. statistics.
    def get_status queue
      begin
        status = ActiveSupport::JSON.decode(RestClient.get("#{@host_addr}/queue/status?queue=#{queue.to_s}"))[0]
      
        # transform result to hash with queue names as keys
        status["members"] = Hash[status["members"].map { |m| [m["agent"], m] }]
        status

      rescue
        return nil
      end
    end
    
    # Method resets queue statistics.
    def reset_queue_stats(queue)
      params = {:queue => queue}
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{@host_addr}/queue/reset", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to reset stats on queue #{queue}: #{e.message}"
      end
    end
    
    # Method pauses agent on queue
    def pause_agent(agent, queue)
      params = {
        :agent => agent,
        :queue => queue,
        :paused => true
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{@host_addr}/queue/pause", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to pause agent: #{e.message}"
      end
    end
    
    # Method unpauses agent from queue
    def unpause_agent(agent, queue)
      params = {
        :agent => agent,
        :queue => queue,
        :paused => false
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{@host_addr}/queue/pause", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to pause agent: #{e.message}"
      end
    end
  end
  
  # Class overrides class PbxisWS and adds caching to it's methods get_status 
  # and reset_queue_status.
  class PbxisWSCached < PbxisWS
    
    def get_status(queue)
      Rails.cache.fetch(queue) do
        super
      end
    end
    
    def reset_queue_stats(queue)
      super
      Rails.cache.delete(queue)
    end
  end
end
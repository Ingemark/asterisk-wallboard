# Module provides API for pbxis-ws.
module Pbxis
  
  class PbxisWS
    
    def initialize(host, port)
      @host_addr = "http://#{host}:#{port}"
    end

    def get_ticket(queues, agents)
      params = {
        :queues => queues,
        :agents => agents
      }
      RestClient.post("#{@host_addr}/ticket", params.to_json, :content_type => :json).to_str.gsub('"', '')
    end
        
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
    
    def get_status queue
      status = ActiveSupport::JSON.decode(RestClient.get("#{@host_addr}/queue/status?queue=#{queue.to_s}"))[0]
      
      # transform result to hash with queue names as keys
      status["members"] = Hash[status["members"].map { |m| [m["agent"], m] }]
      status
    end
    
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
  end
  
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
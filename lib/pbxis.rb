# Module provides API for pbxis-ws.
module Pbxis
  
  class PbxisWS
    
    HOST_ADDR = "http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}"

    def self.get_ticket(queues, agents)
      params = {
        :queues => queues,
        :agents => agents
      }
      RestClient.post("#{HOST_ADDR}/ticket", params.to_json, :content_type => :json).to_str.gsub('"', '')
    end
        
    def self.log_on(agent, queue)
      params = {
        :queue => queue,
        :agent => agent
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{HOST_ADDR}/queue/add", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to log agent on: #{e.message}"
      end
    end
    
    def self.log_off(agent, queue)
      params = {
        :queue => queue,
        :agent => agent
      }
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{HOST_ADDR}/queue/remove", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to log agent on: #{e.message}"
      end
    end
    
    def self.get_status queue
      status = ActiveSupport::JSON.decode(RestClient.get("#{HOST_ADDR}/queue/status?queue=#{queue.to_s}"))[0]
      
      # transform result
      status["members"] = Hash[status["members"].map { |m| [m["memberName"].gsub("SIP/", ""), m] }]
      status["members"].each_value { |m| m["memberName"] = m["memberName"].gsub("SIP/", "") }
      status
    end
    
    def self.reset_queue_stats(queue)
      params = {:queue => queue}
      begin
          response = ActiveSupport::JSON.decode(RestClient.post("#{HOST_ADDR}/queue/reset", params.to_json, :content_type => :json))
          if response["response"] == "Error"
            raise response["response"]
          end
          response
      rescue => e
        raise "An error occurred while trying to reset stats on queue #{queue}: #{e.message}"
      end
    end
  end
end
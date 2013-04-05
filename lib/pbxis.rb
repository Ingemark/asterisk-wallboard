module PbxisFunctions
  # Method logs user on/off.
  #
  # * *Args*  :
  #   - +user+  ->  user to log in
  #   - +queue_id+  ->  id of the queue
  #   - +action+  -> add or remove
  def self.log_on_off(user, queue_id, action)
    if action.to_s != "add" and action.to_s != "remove"
      raise "Unsuported action"
    end
    
    if user.pbx_queues.exists?(queue_id)
      pbxis_params = {
        :queue => PbxQueue.find(queue_id).name,
        :interface => user.extension
      }
      
      begin
          ActiveSupport::JSON.decode(RestClient.post("http://#{Settings.pbxisws[:host]}:#{Settings.pbxisws[:port]}/queue/#{action.to_s}", pbxis_params))
      rescue => e
        raise "An error occurred while trying to log agent #{action.to_s == "add"?"on":"off"}: #{e.message}"
      end
    else
      raise "Queue with id \'#{params[:queue_id]}\' doesn't exist."
    end
  end
end
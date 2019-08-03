module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
 
    def connect
      self.current_user = find_verified_user
    end
 
    private
      def find_verified_user
        cmd = AuthorizeApiRequest.call(request.params)
        if cmd.success?
            @current_user = cmd.result
        else
          Log.create(log_type: Log::ERROR, context: "#authorize_request", message: cmd.errors.to_s)
          reject_unauthorized_connection
        end
      end
  end
end

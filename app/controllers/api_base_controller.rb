class ApiBaseController < ActionController::Base

    include Pundit
    before_action :authorize_request
    
    private
    
    attr_reader :current_user

    def authorize_request
        cmd = AuthorizeApiRequest.call(request.params)
        if cmd.success?
            @current_user = cmd.result
        else
            render json: { error: cmd.errors }, status: 401 
        end
    end
    
end
class ApiBaseController < ActionController::Base

    before_action :authorize_request
    
    private
    
    attr_reader :current_user

    def authorize_request
        @current_user = AuthorizeApiRequest.call(request.headers).result
        render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
    
end
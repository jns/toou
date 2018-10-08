class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_action :authenticate
  
  private
  
  def authenticate
    
    logger.debug("You requested #{request.request_method}")
    logger.debug("Authentication Here...#{request.authorization()}")
    
  end
  
end

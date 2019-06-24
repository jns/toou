class RedemptionController < ApplicationController
    
    layout "redemption"
    skip_before_action :set_user, only: [:index, :toou]
    
    # Display merchant login or redirect to redemption screen
    def index
    end

    # Prompt for toou redemption code    
    def toou
    end
end

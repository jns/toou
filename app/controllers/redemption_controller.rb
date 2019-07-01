class RedemptionController < ApplicationController
    
    layout "redemption"
    skip_before_action :set_user, only: [:toou]

    # Prompt for toou redemption code    
    def toou
    end
end

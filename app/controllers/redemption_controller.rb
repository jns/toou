class RedemptionController < ApplicationController
    
    layout "redemption"

    # Prompt for toou redemption code    
    def toou
        @title = "Redeem"
    end
end

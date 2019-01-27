class WelcomeController < ApplicationController

    skip_before_action :validate_auth_token
    
    # presents the welcome screen
    def index
    end
    
    # presents the about screen
    def about
    end
    
    # Slideshow for primary use cases
    def howitworks
    end
    
    def promotions
        @promotions = Promotion.where(status: Promotion::ACTIVE)
    end
end

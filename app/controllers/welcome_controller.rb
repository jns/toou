class WelcomeController < ApplicationController

    skip_before_action :set_user

    
    # presents the welcome screen
    def index
    end
    
    # presents the about screen
    def about
    end
    
    # Slideshow for primary use cases
    def howitworks
    end
    
    # Send Gifts
    def send_gifts
    end
    
    # View passes
    def passes
    end
    
    # Support page
    def support
    end
    
    # Pass not Found
    def pass_not_found
    end
    
    #View a specific pass
    def pass
        @pass = Pass.find_by(serial_number: params.require([:serial_number]))
        begin 
            authorize @pass
        rescue Pundit::NotAuthorizedError
            redirect_to action: :pass_not_found
        end
    end


end

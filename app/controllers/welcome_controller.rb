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
    
    # View a specific pass
    def pass
        @pass = Pass.find_by(serialNumber: params.require([:serial_number]))
    end
end

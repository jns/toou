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
    end
    
    # Purchase an army pass
    def go_army
        @group = Group.find_by(name: "Army")
        @group_member = "soldier"
        @group_phrase = "Go Army"
        render 'group_beer_purchase'
    end

    def oorah
        @group = Group.find_by(name: "Marines")
        @group_member = "marine"
        @group_phrase = "Oorah!"
        render 'group_beer_purchase'
    end

end

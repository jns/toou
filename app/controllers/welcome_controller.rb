class WelcomeController < ApplicationController

    skip_before_action :set_user

    
    # presents the welcome screen
    def index
        @title = "TooU"
    end
    
    # presents the about screen
    def about
        @title = "About"
    end
    
    # Slideshow for primary use cases
    def howitworks
    end
    
    # Send Gifts
    def send_gifts
        @title = "Send a TooU"
    end
    
    # View passes
    def passes
        @title = "My TooUs"
    end
    
    # Support page
    def support
        @title = "Support"
    end
    
    # Pass not Found
    def pass_not_found
    end
    
    #View a specific pass
    def pass
        @title = "Redeem a TooU"
    end
    
    # Purchase an army pass
    def go_army
        @title = "Go Army"
        @group = Group.find_by(name: "Army")
        @group_member = "Soldier"
        @group_phrase = "Go Army"
        render 'group_beer_purchase'
    end

    def oorah
        @title = "Oorah!"
        @group = Group.find_by(name: "Marines")
        @group_member = "Marine"
        @group_phrase = "Oorah!"
        render 'group_beer_purchase'
    end
    
    def go_navy
        @title = "Go Navy!"
        @group = Group.find_by(name: "Navy")
        @group_member = "Sailor"
        @group_phrase = "Hooyah!"
        render 'group_beer_purchase'
    end

    def flyfightwin
        @title = "Fly, Fight, Win!"
        @group = Group.find_by(name: "Air Force")
        @group_member = "Airman"
        @group_phrase = "Fly, Fight, Win!"
        render 'group_beer_purchase'
    end
    
    def bornready
        @title = "Born Ready"
        @group = Group.find_by(name: "Coast Guard")
        @group_member = "Coastie"
        @group_phrase = "Born Ready"
        render 'group_beer_purchase'
    end 
end

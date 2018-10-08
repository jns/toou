class AuthorizationController < ApplicationController

    skip_before_action :authenticate
    helper OpenIconicHelper
    
    def index
    end
    
    def new_phone
    end
    
    def confirm_phone
        @acct_phone_number = "123-4567"
    end
    
    def two_factor
        @acct_phone_number = "123-4567"
    end
    
end

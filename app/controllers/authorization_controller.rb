class AuthorizationController < ApplicationController

    include MessageSender
    include CodeGenerator
    
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
        phoneNumber = twofactor_params
        MessageSender.send_code(phoneNumber, CodeGenerator.generate)
    end
    
    private
    def twofactor_params
        params.require([:phoneNumber])
    end

end

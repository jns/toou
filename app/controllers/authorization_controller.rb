class AuthorizationController < ApplicationController

    include MessageSender
    helper OpenIconicHelper
    
    skip_before_action :authenticate_request

    def index
    end
    
    def new_phone
    end
    
    def redeem_code
        redemptionCode = getRedemptionCode
        # Lookup phone number or email for redemption code
        @acct_phone_number = "123-4567"
        render 'confirm_phone'
    end
    
    def two_factor
        @acct_phone_number = getPhoneNumber
        acct = Account.find_by_mobile(@acct_phone_number)
        if acct then
            @account_id = acct.id
            otp = acct.generate_otp 
            MessageSender.send_code(@acct_phone_number, otp)
        else 
            flash[:notice] = "Hmm. we can't find your account"
            redirect_to controller: "accounts", action: "new"
        end
    end
    
    def authenticate
        otp, phoneNumber = getOTPparams
           command = AuthenticateUser.call(phoneNumber, otp)
    
       if command.success?
         render json: { auth_token: command.result }
       else
         render json: { error: command.errors }, status: :unauthorized
       end
    end
    
    private
    
    def getRedemptionCode
        params.require(:redemptionCode)    
    end
    
    def getPhoneNumber
        params.require(:phoneNumber)
    end

    def getOTPparams
       params.require([:otp, :phoneNumber]) 
    end

end

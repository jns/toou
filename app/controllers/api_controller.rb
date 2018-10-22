class ApiController < ApplicationController

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_request, only: [:requestOneTimePasscode, :redeemCode, :authenticate]

    # Delivers a one time passcode to the users mobile device 
    #
    # @param [String] phoneNumber The phone number of the device to deliver a one time passcode
    # @param [String] deviceId A unique id of the device 
    # @return 200 For a valid phone number and deviceID
    # @return 400 For an invalid phone number or a suspicious deviceId    
    def requestOneTimePasscode
        acct_phone_number, device_id = params.require([:phoneNumber, :deviceId])
        if isValidPhone(acct_phone_number) then
            acct = Account.find_or_create_by(mobile: acct_phone_number)
            if acct then
                # Todo check the device ID and get worried if it changed
                otp = acct.generate_otp 
                #MessageSender.new.send_code(acct_phone_number, otp)
                render json: {passcode: otp}, status: :ok 
            else 
                render status: :bad_request, json: {error: "There was as problem finding or creating an account."}
            end
        else
            render status: :bad_request, json: {error: "Invalid phone number."}
        end
    end
    
    # Delivers a one time passcode to the users mobile device
    # based on a redemption code linked to a mobile device
    #
    # @param [String] redemptionCode the redemption code 
    # @return 200 For a valid redemption code
    # @return 400 For an invalid redemption code
    def redeemCode
        
    end
    
    # Authenticates the parameters and returns a json web token
    # @param [String] phoneNumber The phone number of the device to authenticate
    # @param [String] passCode a one time passcode returned by requestOneTimePasscode
    # @param [String] deviceId a unique id of the device
    # @param 200 {"auth_token", jwt} a json web token or 401 for an invalid set of credentials
    def authenticate
        otp, phoneNumber = params.require([:passCode, :phoneNumber, :deviceId])
        command = AuthenticateUser.call(phoneNumber, otp)
    
       if command.success?
         render json: { auth_token: command.result }, status: :ok
       else
         render json: { error: command.errors }, status: :unauthorized
       end
    end
    
    # Returns available passes for authenticated user
    # 
    def passes
        render json: @current_user.passes, status: :ok
    end
    
    
    
    private
    
    def isValidPhone(phone)
        true    
    end
    
    
end

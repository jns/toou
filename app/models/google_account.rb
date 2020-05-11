class GoogleAccount < Account
   
    before_validation on: :create do authentication_method = AUTHX_OAUTH end
    
end
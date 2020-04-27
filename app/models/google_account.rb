class GoogleAccount < Account
   
    before_create { authentication_method = AUTHX_OAUTH }
    
end
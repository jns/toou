class EmailAccount < Account
   
    before_create { self.authentication_method = AUTHX_PASSWORD }
    has_secure_password

end
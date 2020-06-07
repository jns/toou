class Account < ActiveRecord::Base
    
    AUTHX_OTP = "One Time Password"
    AUTHX_PASSWORD = "Password"
    AUTHX_OAUTH = "Oauth"
    
    has_many :passes, as: :recipient
    belongs_to :user
    
    validates :authentication_method, inclusion: {in: [AUTHX_OTP, AUTHX_PASSWORD, AUTHX_OAUTH], message: "Invalid authentication method"}

    def missing_fields
       result = []
       result << :name unless name
       result << :email unless email
       result << :phone_number unless phone_number
       return result
    end
    
    
    def to_s
        if name
           name
        else
            phone_number
        end
    end
end

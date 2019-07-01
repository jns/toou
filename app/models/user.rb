class User < ApplicationRecord
    
    attr_accessor :reset_token
    
    TEST_USERNAME = "tester"
    TEST_PASSCODE = "000000"
    
    before_save { self.email = email.downcase }
    validates :username,  presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
                    
    has_secure_password
    has_and_belongs_to_many :roles
    
    def User.new_token
       SecureRandom.urlsafe_base64 
    end
    
    # Returns the hash digest of the given string.
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end
    
    def admin?
       roles.member?(Role.admin) 
    end
    
    def merchant?
       roles.member?(Role.merchant) 
    end
    
    def tester?
        self.username == TEST_USERNAME and roles.member?(Role.tester)
    end
    
    def merchant
       if merchant?
           Merchant.find_by(user: self)
       else
           nil
       end
    end
    
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest,  User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    
    def password_reset_expired?
       reset_sent_at < 1.hour.ago 
    end
end

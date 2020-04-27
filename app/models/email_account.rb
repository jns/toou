class EmailAccount < Account
   
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    before_create { self.authentication_method = AUTHX_PASSWORD }
    before_save { self.email = email.downcase }
    validates :email, presence: true, length: { maximum: 255 },
                     format: { with: VALID_EMAIL_REGEX },
                     uniqueness: { case_sensitive: false }
    
    has_secure_password

    scope :active_reset, ->() { where("reset_sent_at > ?", 10.minutes.ago)}
    
    # Generates a random token
    def EmailAccount.new_token
       SecureRandom.urlsafe_base64 
    end
    
    # Returns the hash digest of the given string.
    def EmailAccount.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end
    
    # Returns the user that matches the given reset token or nil
    def EmailAccount.with_reset_token(token)
       User.active_reset.find{|u| BCrypt::Password.new(u.reset_digest) == token}
    end
    
    def authenticated?(attribute, token)
      digest = send("#{attribute}_digest")
      return false if digest.nil?
      BCrypt::Password.new(digest).is_password?(token)
    end

    
    def create_reset_digest
        self.reset_token = EmailAccount.new_token
        update_attribute(:reset_digest,  EmailAccount.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end
    
    def password_reset_expired?
       reset_sent_at < 1.hour.ago 
    end

end
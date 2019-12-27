class JsonWebToken
 
  class << self
  
    def encode(payload, exp = nil, secret = Rails.application.secrets.secret_key_base)
      payload[:exp] = exp.to_i if exp
      JWT.encode(payload, secret, 'HS256')
    end
 
    def decode(token, secret = Rails.application.secrets.secret_key_base)
      begin
       body = JWT.decode(token, secret, true, {algorithm: 'HS256'})[0]
       HashWithIndifferentAccess.new body
     rescue
       nil
     end
    end
  
  end
  
end
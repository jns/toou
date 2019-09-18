class Secret
   
   
   # Queries if the secret exists
   def Secret.exists?(secret)
       @@secrets[secret] ? true : false
   end
   
   # Returns the value associated with the secret, then removes the secret and its value
   def Secret.find(secret)
       @@secrets.delete secret
   end
   
   # Creates a temporary secret that can be accessed one time to return the associated value
   def Secret.create(value)
       secret = Array.new(30){ [*'0'..'9',*'A'..'Z'].sample }.join 
       @@secrets[secret] = value
       removeSoon(secret)
       secret
   end
   
   private
   
  @@secrets = {}

   def Secret.removeSoon(secret, delay=60)
        Thread.new {
            sleep delay
            @@secrets.delete secret
        }
   end
end
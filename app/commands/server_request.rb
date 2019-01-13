class ServerRequest
   
   @@delegate = Net::HTTP
   
   def ServerRequest.delegate=(delegate)
        @@delegate = delegate    
   end
   
   def post(uri, payload, headers)
       @@delegate.post(uri, payload, headers)
   end
    
end
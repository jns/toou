class ServerRequest
   
   @@delegate = Net::HTTP
   
   def ServerRequest.delegate=(delegate)
        @@delegate = delegate    
   end
   
   def post(uri, payload, headers)
      puts uri.host
      puts uri.port
      puts uri.path
      puts payload
      puts headers
      
      http = @@delegate.new(uri.host, uri.port) 
      http.use_ssl = true
      response = http.post2(uri.path, payload, headers)
      puts response.status
   end
    
end
class MockServer
   @@requests = []
   
   def MockServer.requests
      @@requests 
   end
   
   def MockServer.post(uri, payload, headers)
        @@requests << {uri: uri, payload: payload, headers: headers}
        return Net::HTTPOK.new(1, 200, "Mock ok Response")
   end
    
end
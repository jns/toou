class MockServer
   
   attr_accessor :use_ssl
   
   @@requests = []
   
   def MockServer.requests
      @@requests 
   end
   
   def MockServer.post(uri, payload, headers)
        @@requests << {uri: uri, payload: payload, headers: headers}
        return Net::HTTPOK.new(1, 200, "Mock ok Response")
   end
   
   def initialize(host, port)
   end
   
   def request_post(path, payload, headers)
   end
   
   def post2(path, payload, headers)
   end
end
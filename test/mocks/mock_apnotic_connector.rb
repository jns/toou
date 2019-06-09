class MockApnoticConnector
   
   class Response
      def status
         "200"
      end
      
      def body
         ""
      end
      
      
      def ok?
         true
      end
   end
   
   cattr_accessor :notifications
   self.notifications = []
   
   def initialize(options={})
      @options = options
   end
   
   def push(notification)
       self.notifications << {options: @options, notification: notification}
       Response.new
   end
   
   def close
   end
   
    
end
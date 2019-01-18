class MockStripeCustomer
   
   attr_reader :options, :id
   
   def MockStripeCustomer.create(options = {})
       MockStripeCustomer.new(options)
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
   end
    
end
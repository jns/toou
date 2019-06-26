class MockStripeCharge
   
   INVALID_PAYMENT = "invalid_payment"
   
   cattr_accessor :charges
   self.charges = []
   
   attr_reader :options, :id
   
   def MockStripeCharge.create(options = {})
      if options[:source] === INVALID_PAYMENT
         throw Stripe::CardError("INVALID PAYMENT")
      end
       c = MockStripeCharge.new(options)
       self.charges << c
       return c
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = "ch" + rand(100000...999999).to_s
   end
   
   def to_s
      "[MockStripeCharge:id=#{@id}]"
   end
    
end
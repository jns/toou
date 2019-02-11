class MockStripeCharge
   
   cattr_accessor :charges
   self.charges = []
   
   attr_reader :options, :id
   
   def MockStripeCharge.create(options = {})
       c = MockStripeCharge.new(options)
       self.charges << c
       return c
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
   end
   
   def to_s
      "[MockStripeCharge:id=#{@id}]"
   end
    
end
class MockStripeCustomer
   
   cattr_accessor :customers
   self.customers = []
   
   attr_reader :options, :id, :sources
   
   def MockStripeCustomer.create(options = {})
       c = MockStripeCustomer.new(options)
       self.customers << c
       return c
   end
   
   def MockStripeCustomer.retrieve(id)
      self.customers.find do |c|
         c.id == id
      end or create()
      
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
      @sources = MockStripeSources.new
   end
    
end
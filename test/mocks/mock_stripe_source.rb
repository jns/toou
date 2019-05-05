class MockStripeSource
   
   cattr_accessor :sources
   self.sources = []
   
   attr_reader :options, :id
   
   def MockStripeSource.create(options = {})
       s = MockStripeSource.new(options)
       self.sources << s
       return s
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
   end
   
   def to_s
      "[MockStripeSource:id=#{@id}]"
   end
    
end
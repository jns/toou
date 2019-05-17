class MockStripeTransfer
   
   cattr_accessor :transfers
   self.transfers = []
   
   attr_reader :options, :id
   
   def MockStripeTransfer.create(options = {})
       t = MockStripeTransfer.new(options)
       self.transfers << t
       return t
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
   end
   
   def to_s
      "[MockStripeTransfer:id=#{@id}]"
   end
    
end
class MockStripePaymentMethod
   
   class Card
      attr_accessor :fingerprint
      
      def initialize()
         @fingerprint = Array.new(10){ [*'0'..'9',*'A'..'Z'].sample }.join
      end
   end 
   
   cattr_accessor :methods
   self.methods = []
   
   attr_reader :options, :id, :card
   
   def MockStripePaymentMethod.create(options = {})
       pm = MockStripePaymentMethod.new(options)
       self.methods << pm
       return pm
   end
   
   def initialize(options = {})
      @options ||= {}
      @options.merge(options)
      @id = rand(100000...999999).to_s
      @card = Card.new
   end
   
   def to_s
      "[MockStripePaymentMethod:id=#{@id}]"
   end
   
end
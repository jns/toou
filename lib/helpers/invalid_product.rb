class InvalidProduct
   
   attr_reader :name, :max_price_cents, :icon
   
   def initialize
      @name = "invalid"
      @max_price_cents = 0
      @icon = "invalid"
   end
    
end
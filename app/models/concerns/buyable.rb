module Buyable
   
    # Returns the price of the buyable object
    # in the specified units (either :cents or :dollars)
    # Optionally takes a merchant in which case merchant specific pricing
    # is returned.  If the merchant cannot redeem the buyable object then it returns 
    # the maximum price of the product
    def price(units, merchant=nil)
        
        factor = case units
        when :cents
            1
        when :dollars
            100.0
        end
        
        if self.method(:price_cents).arity === 0
            (price_cents/factor).to_i
        else
            price_cents(merchant)/factor
        end
    end
    
end
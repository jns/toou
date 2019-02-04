module Buyable
   
    def price(units, currency = :usd)
        case units
        when :cents
            price_cents
        when :dollars
            price_cents/100.0
        end
    end
    
end
class InvalidPass

    attr_reader :serial_number, :expiration, :message, :status, :value_cents
    
    def initialize(serialNumber)
        @serial_number = serialNumber
        @message  = ""
        @expiration = Time.new
        @status = "INVALID"
        @value_cents = 0
    end
    
    def purchaser
        return InvalidRecipient.new
    end
    
    def buyable
       return InvalidProduct.new 
    end
    
    def value_dollars
        return 0.0
    end
end

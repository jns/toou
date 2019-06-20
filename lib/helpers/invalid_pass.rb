class InvalidPass

    attr_reader :serial_number, :expiration, :message, :status
    
    def initialize(serialNumber)
        @serial_number = serialNumber
        @message  = ""
        @expiration = Time.new
        @status = "INVALID"
    end
    
    def purchaser
        return InvalidRecipient.new
    end
    
    def buyable
       return InvalidProduct.new 
    end
end

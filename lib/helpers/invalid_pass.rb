class InvalidPass

    attr_reader :serial_number, :expiration, :message, :passTypeIdentifier, :status
    
    def initialize(serialNumber, type = "pass.com.eloisaguanlao.testpass")
        @serial_number = serialNumber
        @passTypeIdentifier = type
        @message  = ""
        @expiration = ""
        @status = "INVALID"
    end
    
    def purchaser
        return InvalidRecipient.new
    end
    
    def buyable
       return InvalidProduct.new 
    end
end

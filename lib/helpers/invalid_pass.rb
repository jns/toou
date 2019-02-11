class InvalidPass

    attr_reader :serialNumber, :expiration, :message, :passTypeIdentifier, :status
    
    def initialize(serialNumber, type = "pass.com.eloisaguanlao.testpass")
        @serialNumber = serialNumber
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

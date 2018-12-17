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
       "" 
    end
    
end

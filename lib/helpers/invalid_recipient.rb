class InvalidRecipient

    attr_reader :name, :primary_phone_number, :email
    
    def initialize() 
        @name = "invalid"
        @primary_phone_number = "invalid"
        @email = "invalid"
    end
end

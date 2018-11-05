class SerialNumber
    
    def SerialNumber.isValid?(sn) 
        0 == (sn =~ /^[a-zA-Z0-9]*$/)
    end
    
end
class SerialNumber
    
    def SerialNumber.isValid?(sn) 
        0 == (sn =~ /^[a-z]*[0-9]*$/)
    end
    
end
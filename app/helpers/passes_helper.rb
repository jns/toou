module PassesHelper

    
    def pkpassUrl(p) 
        "/v1/passes/#{p.passTypeIdentifier}/#{p.serial_number}"    
    end
    
  def passRootDir 
    File.join(Rails.root, "passes")  
  end
  
  def pkpassTemplateDir
    File.join(Rails.root, "lib", "assets", "pkPassTemplate")
  end
  
  def pkpassCertificateDir
    File.join(Rails.root, "lib", "assets", "certificates")
  end
   
  # The filename of the signed and compressed pass
  def passFileName(p)
    File.join(passRootDir, "#{p.serial_number}.pkpass")
  end
  
  # Returns the name of the directory on the server that stores the pass
  def passDirectory(p)
    File.join(passRootDir, "#{p.serial_number}.pass")
  end 

end

module PassesHelper

    
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
    File.join(passRootDir, "#{p.serialNumber}.pkpass")
  end
  
  # Returns the name of the directory on the server that stores the pass
  def passDirectory(p)
    File.join(passRootDir, "#{p.serialNumber}.pass")
  end 

end

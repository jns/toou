
require 'dubai'

class PassBuilderJob < ActiveJob::Base

  queue_as :default
  
  def passRootDir 
    File.join(Rails.root, "passes")  
  end
  
  def pkpassTemplateDir
    File.join(Rails.root, "lib", "assets", "pkPassTemplate")
  end
  
  def pkpassCertificateDir
    File.join(Rails.root, "lib", "assets", "certificates")
  end
  
  def perform(*passids)
    
    # Build a pkpass for each passid
    passids.each() do |passid|
      p = Pass.find(passid)
      createTemplateDirectoryForPass(p)
      createPassJson(p)
      buildPass(p)
    end
    
  end
 
  # The filename of the signed and compressed pass
  def passFileName(p)
    File.join(passRootDir, "#{p.serialNumber}.pkpass")
  end
  
  # Returns the name of the directory on the server that stores the pass
  def passDirectory(p)
    File.join(passRootDir, "#{p.serialNumber}.pass")
  end
  
  # Creates the pass directory and populates it with template resources
  def createTemplateDirectoryForPass(p)
    passDir = passDirectory(p)
    FileUtils.mkdir_p(passDir) unless File.exists?(passDir) 
    Dir.glob(File.join(pkpassTemplateDir, "*")).each do |file|
      FileUtils.cp_r(file, passDir)
    end
  end
  
  # Creates the pass.json file in the appropriate pass directory
  def createPassJson(p)
    pkpass = {}
    pkpass[:description] = "A TooU payment pass"
    pkpass[:formatVersion] = 1
    pkpass[:organizationName] = "Josh Shapiro"
    pkpass[:passTypeIdentifier] = "pass.com.eloisaguanlao.testpass"
    pkpass[:serialNumber] = p.serialNumber
    pkpass[:teamIdentifier] = "8Q9F954LPX"
    pkpass[:expirationDate] = p.expiration.iso8601
    pkpass[:voided] = false
    pkpass[:logoText] = "Drink TooU"
    pkpass[:backgroundColor] = "rgb(10, 10, 10)"
    pkpass[:labelColor] = "rgb(255, 255, 255)"
    pkpass[:foregroundColor] = "rgb(255, 255, 255)"
    pkpass[:generic] = {
      :primaryFields => [
        {:key => "message", :label => "", :value => p.message}
      ],
      :secondaryFields => [
        {:key => "expiration", :label => "EXPIRES", :value => p.expiration.iso8601, :isRelative => true, :dateStyle => "PKDateStyleShort"}
      ]
    }
    
    File.open(File.join(passDirectory(p), "pass.json"), "w+") do |f|
      f.puts pkpass.to_json
    end
  end

  # Builds and signs the pass  
  def buildPass(p)
    
    Dubai::Passbook.certificate, Dubai::Passbook.password = File.join(pkpassCertificateDir, "PassSigningCert.p12"), ENV['PKPASS_CERTIFICATE_PASSWORD']

    # Example.pass is a directory with files "pass.json", "icon.png" & "icon@2x.png"
    File.open(passFileName(p), 'w+') do |f|
      f.write Dubai::Passbook::Pass.new(passDirectory(p)).pkpass.string
    end
    
  end

end
  


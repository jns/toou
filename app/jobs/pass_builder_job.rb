
require 'dubai'

# 
# This class builds and signs pkpasses 
# 
# Assumptions:
# - Existence of an environment variable PKPASS_CERTIFICATE_PASSWORD
# - A template directory for passes in Rails.root/lib/assets/pkPassTemplate 
# - Private certificates located in Rails.root/lib/assets/certificates
# - Signed passes are stored in Rails.root/passes
#
# Production versions must migrate this class off the web server and use 
# configuration to specify locations of templates, certificates, and passes
class PassBuilderJob < ActiveJob::Base

  include PassesHelper
  
  queue_as :default
  
  
  def perform(*passids)
    
    # Build a pkpass for each passid
    passids.each() do |passid|
      p = Pass.find(passid)
      createTemplateDirectoryForPass(p)
      createPassJson(p)
      buildPass(p)
    end
    
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
    pkpass[:passTypeIdentifier] = p.passTypeIdentifier
    #pkpass[:authenticationToken] = "FIXME"
    # pkpass[:webServiceURL] = ENV['WEB_SERVICE_URL']
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
  


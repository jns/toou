
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
      begin 
        p = Pass.find(passid)
        createTemplateDirectoryForPass(p)
        createPassJson(p)
        buildPass(p)
      rescue Exception => e
        Log.create(log_type: Log::ERROR, context: "PassBuilderJob", current_user: "", message: e.message) 
      end
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
    
    authToken = JsonWebToken.encode(pass_id: p.id) or throw "Error generating web token for pass #{p.serial_number}"
    webServiceUrl = ENV["WEB_SERVICE_URL"] or throw "Environment variable for WEB_SERVICE_URL is missing"
    
    pkpass = {}
    pkpass[:description] = "A TooU Drink Coupon"
    pkpass[:formatVersion] = 1
    pkpass[:organizationName] = "Josh Shapiro"
    pkpass[:passTypeIdentifier] = p.passTypeIdentifier
    pkpass[:authenticationToken] = authToken
    pkpass[:webServiceURL] = webServiceUrl
    pkpass[:serialNumber] = p.serial_number
    pkpass[:teamIdentifier] = "8Q9F954LPX"
    pkpass[:expirationDate] = p.expiration.iso8601
    pkpass[:voided] = p.expired?
    pkpass[:logoText] = "Treat Someone"
    pkpass[:backgroundColor] = "rgb(131, 214, 222)"
    pkpass[:labelColor] = "rgb(142, 142, 142)"
    pkpass[:foregroundColor] = "rgb(250, 250, 250)"
    pkpass[:locations] = [{"latitude" => 32.8306228, "longitude" => -117.1414313}]
    pkpass[:barcodes]  =[{
         "format" => "PKBarcodeFormatCode128",
         "message" => p.barcode_payload,
         "messageEncoding" => "iso-8859-1"}]
    pkpass[:storeCard] = {
      :primaryFields => [
        {:key => "message", :label => "", :value => ""}
      ],
      :backFields => [
        {:key => "instructions", :label => "", :value => "Redeem at Quantum Brewing"}
      ],
      :secondaryFields => [ 
        {:key => "message", :label => "Message", :value => p.message},
        {:key => "sender", :label => "Sender", :value => p.purchaser.phone_number.to_s}
      ]
    }
    
    File.open(File.join(passDirectory(p), "pass.json"), "w") do |f|
      f.puts pkpass.to_json
    end
  end

  # Builds and signs the pass  
  def buildPass(p)
    
    certificatePassword = ENV['PKPASS_CERTIFICATE_PASSWORD'] or throw "Enivornment Variable for PKPASS_CERTIFICATE_PASSWORD is missing"
    Dubai::Passbook.certificate, Dubai::Passbook.password = File.join(pkpassCertificateDir, "PassSigningCert.p12"), certificatePassword
    
    # Example.pass is a directory with files "pass.json", "icon.png" & "icon@2x.png"
    File.open(passFileName(p), 'w') do |f|
      f.write Dubai::Passbook::Pass.new(passDirectory(p)).pkpass.string
    end
    
  end

end
  


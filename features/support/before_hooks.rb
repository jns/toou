
require File.expand_path( File.join(File.dirname(__FILE__), "../../test/test_helper.rb") )

include TestEnvironment


Before do
    Rails.application.load_seed
    @people = []
    @beer = Product.find_or_create_by(name: "Beer")
    
    Account.destroy_all
    Order.destroy_all
    Pass.destroy_all
    
    FakeSMS.messages.clear
    MessageSender.client = FakeSMS
    
    SendDeviceNotification.connector = MockApnoticConnector
end


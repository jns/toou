
require File.expand_path( File.join(File.dirname(__FILE__), "../../test/test_helper.rb") )

include TestEnvironment


Before do
    Rails.application.load_seed
    @people = []
    @beer = Product.find_or_create_by(name: "Beer")
    @beer.update(max_price_cents: 1000)
    Account.destroy_all
    Order.destroy_all
    Pass.destroy_all
    
    @admin_account = Account.find_or_create_by(phone_number: "+11111111111")
    
    FakeSMS.messages.clear
    MessageSender.client = FakeSMS
    
    SendDeviceNotification.connector = MockApnoticConnector
end


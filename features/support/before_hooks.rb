
require File.expand_path( File.join(File.dirname(__FILE__), "../../test/test_helper.rb") )

include TestEnvironment

Before do
    Rails.application.load_seed
    @people = []
    
    FakeSMS.messages.clear
    MessageSender.client = FakeSMS
    
    ServerRequest.delegate = MockServer
end


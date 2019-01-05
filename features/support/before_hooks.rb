
require File.expand_path( File.join(File.dirname(__FILE__), "../../test/test_helper.rb") )

include TestEnvironment

Before do
    @people = []
    
    FakeSMS.messages.clear
    MessageSender.client = FakeSMS
end
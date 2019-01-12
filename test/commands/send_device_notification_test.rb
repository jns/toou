require 'test_helper'
require 'net/http'
class SendDeviceNotificationTest < ActiveJob::TestCase

    def setup
        ENV["APN_SERVER"] = "http://127.0.0.1:8181"
        @app = Proc.new do |env|
            ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
        end
 
        @rackpid = fork do
            Signal.trap("HUP") {exit}
            Rack::Handler::WEBrick.run(@app, {:Port => 8181, :Logger => Rack::NullLogger})
        end
    end
    
    def teardown
       Process.kill("HUP", @rackpid)
    end
    
    test "Rack Server Works" do
       response = Net::HTTP.get_response(URI(ENV["APN_SERVER"]))
       assert  response.is_a?(Net::HTTPSuccess)
    end

    test "Cannot send notifications to account that does not support notifications" do
        account = accounts(:josh)
        assert_equal false, account.can_receive_notifications?
        
        cmd = SendDeviceNotification.call(account)
        assert_equal false, cmd.success?
        assert_not_nil cmd.errors[:not_supported]
    end
    
    test "Can send notifications to account with device_id" do
        account = accounts(:notifiable)
        assert account.can_receive_notifications?
        
        cmd = SendDeviceNotification.call(account)
        assert cmd.success
    end
end

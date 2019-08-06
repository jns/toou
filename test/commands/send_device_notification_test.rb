require 'test_helper'
require 'net/http'
class SendDeviceNotificationTest < ActiveJob::TestCase

    def setup
    end
    
    def teardown
    end

    test "Cannot send notifications to account that does not support notifications" do
        account = accounts(:josh)
        assert_equal false, account.can_receive_notifications?
        
        cmd = SendDeviceNotification.call(account, "title", "a message")
        assert_equal false, cmd.success?
        assert_not_nil cmd.errors[:not_supported]
    end
    
    test "Can send notifications to account with device_id" do
        account = accounts(:notifiable)
        assert account.can_receive_notifications?
        
        cmd = SendDeviceNotification.call(account, "title",  "a message")
        assert cmd.success?
    end
end

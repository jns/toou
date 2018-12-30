
#
# An item returned as part of the account history
#
class HistoryItem
    
    SEND_ACTIVITY_TYPE = "SEND"
    RECEIVE_ACTIVITY_TYPE = "RECEIVE"
    
    attr_accessor :date, :activity_type, :message   
end
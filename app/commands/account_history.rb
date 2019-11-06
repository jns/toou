
class AccountHistory
    
    prepend SimpleCommand
    
    def initialize(account)
       @account = account 
    end
    
    def call
        
        unless @account
            errors.add :invalid_params, "Account is nil"
            return nil
        end
        
        history = []
        @account.orders.each { |order|
            item = HistoryItem.new()
            item.id = "#{order.id}R"
            item.date = order.created_at
            item.activity_type = HistoryItem::SEND_ACTIVITY_TYPE
            if order.passes.count == 1 then
               item.message = "You sent a drink to #{order.passes.first.recipient.to_s}"
            else 
               item.message = "You sent drinks to #{order.recipients.collect{|r| r.phone_number}.join(",")}" 
            end
            history << item
        }
        
        @account.passes.each {|pass|
            item = HistoryItem.new()
            item.id = "#{pass.id}S"
            item.date = pass.created_at
            item.activity_type = HistoryItem::RECEIVE_ACTIVITY_TYPE
            item.message = "You received a drink from #{pass.purchaser.phone_number}"
            history << item
        }
        
        return history.sort{|a,b| a.date <=> b.date}
    end
end

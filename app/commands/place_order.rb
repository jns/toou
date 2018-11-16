#  
#  Takes an account, and a list 
class PlaceOrder

    prepend SimpleCommand
  
    def initialize(account, recipients, message)
        @account = account
        @recipients = recipients
        @message = message
    end
    
    def call
        begin
            o = Order.new
            ActiveRecord::Base.transaction do 
                o.account = @account
                o.save
                @recipients.each{ |r| 
                    p = create_pass(r, o)
                    p.save
                }
            end
            return o
        rescue 
            return errors.add(:internal_server_error, "Error creating order")
        end
    end
    
    private
    
    def create_pass(recipient, order) 
       p = Pass.create
       p.message = @message
       p.expiration = Date.today + 8.days
       p.account = Account.search_or_create_by_recipient(recipient)
       p.order = order
       return p
    end
    
end
#  
#  Takes an account, and a list of recipients
#  generates an order with a set of passes
class PlaceOrder

    prepend SimpleCommand
  
    # Recipients are specified as key value pairs with keys phoneNumber: , name:, and email:
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
                throw "Error creating order for account #{@account.primary_phone_number}" unless o.save  
                @recipients.each{ |r| 
                    p = create_pass(r, o)
                    throw "Error create pass for order #{o.id}" unless p.save 
                }
            end
            return o
        rescue => e
            return errors.add(:internal_server_error, "Error creating order: #{e.message}")
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
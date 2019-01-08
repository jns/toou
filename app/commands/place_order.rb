#  
#  Takes an account, and a list of recipients
#  generates an order with a set of passes
class PlaceOrder

    prepend SimpleCommand
  
    # Recipients are specified as an array of phone numbers 
    def initialize(account, recipients, message)
        @account = account
        @recipients = recipients
        @message = message
    end
    
    def call
        begin
            order = Order.new
            ActiveRecord::Base.transaction do
                order.account = @account
                @recipients.each{ |r| 
                    throw "Recipient phone number cannot be empty" unless r
                    # This will format the phone number
                    create_pass(PhoneNumber.new(r).to_s, order)
                }
            end
            return order
        rescue => e
            message = "Error creating order: #{e.message}"
            Log.create(log_type: Log::ERROR, context: self.class.name, current_user: @account.id, message: message)
            errors.add(:internal_server_error, message)
        end
    end
    
    private
    
    def create_pass(recipient_phone, order) 
       p = Pass.create
       p.message = @message
       p.expiration = Date.today + 8.days
       p.account = Account.find_or_create_by(phone_number: recipient_phone)
       p.order = order
       p.save
    end
    
end
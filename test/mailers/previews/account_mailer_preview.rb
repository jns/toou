class AccountMailerPreview < ActionMailer::Preview
   
   def welcome  
       AccountMailer.with(account: Account.first).welcome
   end 
   
   def purchase_receipt
      AccountMailer.with(order: Order.first).purchase_receipt
   end
end
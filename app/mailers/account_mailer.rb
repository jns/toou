class AccountMailer < ApplicationMailer
   
    def welcome
       account = params[:account]
        @greeting = "Hi #{account.to_s}"
       email_with_name = %("#{account.name}" <#{account.email}>)
        mail(to: email_with_name, bcc: "support@toou.gifts", subject: 'Welcome to tooU')
    end
    
    def purchase_receipt
        attachments.inline['TooULogoMini.png'] = File.read(File.join([Rails.root, "app", "assets", "images", "TooULogoMini.png"]))
        @order = params[:order]
        @account = @order.account
       email_with_name = %("#{@account.name}" <#{@account.email}>)
        mail(to: email_with_name, bcc: "support@toou.gifts", subject: "Receipt from tooU")
    end
end
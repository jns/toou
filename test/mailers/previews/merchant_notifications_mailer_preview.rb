# Preview all emails at http://localhost:3000/rails/mailers/merchant_notifications_mailer
class MerchantNotificationsMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/merchant_notifications_mailer/passcode
  def passcode_email
    MerchantNotificationsMailer.passcode_email
  end

end

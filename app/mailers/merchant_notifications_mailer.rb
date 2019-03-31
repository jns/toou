class MerchantNotificationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.merchant_notifications_mailer.passcode.subject
  #
  def passcode_email
    @greeting = "Hi"
    user = params[:user]
    mail to: user.email
  end
end

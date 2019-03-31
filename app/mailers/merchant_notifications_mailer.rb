class MerchantNotificationsMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.merchant_notifications_mailer.passcode.subject
  #
  def passcode_email
    user = params[:user]
    @greeting = "Hi #{user.email}"
    @passcode = params[:passcode]
    mail to: user.email, subject: "TooU Temporary Passcode"
  end
end

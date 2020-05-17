class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.merchant_notifications_mailer.passcode.subject
  #
  def password_reset
    account = params[:account]
    @greeting = "Hi #{account.user.username}"
    @url = params[:url]
    mail to: account.email, subject: "TooU Password Reset"
  end
end

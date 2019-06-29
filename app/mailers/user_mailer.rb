class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.merchant_notifications_mailer.passcode.subject
  #
  def password_reset
    user = params[:user]
    @greeting = "Hi #{user.username}"
    @url = params[:url]
    mail to: user.email, subject: "TooU Password Reset"
  end
end

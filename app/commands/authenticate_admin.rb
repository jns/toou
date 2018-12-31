class AuthenticateAdmin
  
  prepend SimpleCommand
  
  def initialize(username, password)
    @username = username
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :username, :password

  def user
    user = AdminAccount.find_by_username(username)
    return user if user && user.try(:authenticate, password)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
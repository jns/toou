class PasswordResetsController < ApplicationController

  skip_before_action :set_user
  
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def edit
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      UserMailer.password_reset(self).deliver_now
      flash[:info] = "We sent you an email with password reset instructions"
      redirect_to login_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      set_user @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to home_url_for(@user)
    else
      render 'edit'
    end
  end
  

  def home_url_for(user) 
    if user.merchant?
      merchants_url
    elsif user.admin?
      admin_dashboard
    else
      root_url
    end
  end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
  
  
    # Before filters

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to login_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end

module Admin
class AccountsController < AdminController
  
  before_action :set_account, only: [:show]
  
  # GET /accounts
  # GET /accounts.json
  def index
    authorize Account
    @accounts = policy_scope(Account)
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    authorize(@account)
  end

 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

end
end
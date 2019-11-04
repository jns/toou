module Admin
class AccountsController < AdminController
  
  before_action :set_account, except: [:index]
    skip_before_action :authorize_admin, only: [:update]

  # GET /accounts
  # GET /accounts.json
  def index
    authorize Account
    @accounts = policy_scope(Account).sort{|a,b| b.created_at <=> a.created_at}
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    authorize(@account)
    @groups = Group.all
  end

  def update
    authorize @account, policy_class: AdminMerchantPolicy
    groups = params[:group_ids] || []
    @account.groups.clear
    groups.each do |group_id|
      @account.groups << Group.find(group_id)
    end
    redirect_to action: :show
  end
 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

end
end
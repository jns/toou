module Admin
class MerchantsController < AdminController

  def index
    @merchants = Merchant.all
  end

  def show
    @merchant = Merchant.find(params[:id])
  end 
  
  def update
      @merchant = Merchant.find(params[:id])
      @merchant.logo.attach merchant_params["logo"]
      redirect_to :admin_merchant
  end
  
  private
  
    def merchant_params
        params.require(:merchant).permit(:logo)
    end
end
end
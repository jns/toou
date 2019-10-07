module Admin
class OrdersController < AdminController

  before_action :set_order, only: [:show]

  # GET /orders
  # GET /orders.json
  def index
    authorize Order
    @orders = policy_scope(Order).sort{|o1, o2| o2.created_at <=> o1.created_at}
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order.show?
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = policy_scope(Order).find(params[:id])
    end

end
end

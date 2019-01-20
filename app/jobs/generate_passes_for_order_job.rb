class GeneratePassesForOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)

  end
  
  private
    

end

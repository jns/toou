class AddFeeToProducts < ActiveRecord::Migration[5.2]
  def up
    add_column :products, :fee_cents, :integer
    Product.all.each{|p| p.update(fee_cents: 125)}
  end
  
  def down
    remove_column :products, :fee_cents
  end
end

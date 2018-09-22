class RemovePurchaserFromPass < ActiveRecord::Migration
  def change
    remove_column :passes, :purchaser_id
  end
end

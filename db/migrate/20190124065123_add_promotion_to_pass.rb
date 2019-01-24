class AddPromotionToPass < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :promotion_id, :bigint
  end
end

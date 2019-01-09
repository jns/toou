class AddRedemptionCodeColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :redemption_code, :string
  end
end

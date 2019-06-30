class ChangeDevicesToMerchant < ActiveRecord::Migration[5.2]
  def change
    change_table :devices do |t|
      t.belongs_to :merchant
      t.remove :user_id
    end
  end
end

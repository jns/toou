class AddRedeemedByToGroupPass < ActiveRecord::Migration[5.2]
  def change
    change_table :passes do |t|
      t.belongs_to :redeemed_by, foreign_key: {to_table: :accounts}
    end
  end
end

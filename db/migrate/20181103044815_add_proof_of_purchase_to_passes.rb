class AddProofOfPurchaseToPasses < ActiveRecord::Migration[5.2]
  def change
    add_column :passes, :proof_of_purchase, :string
  end
end

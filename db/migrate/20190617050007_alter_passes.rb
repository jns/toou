class AlterPasses < ActiveRecord::Migration[5.2]
  def change
    change_table :passes do |t|
      t.remove :passTypeIdentifier
      t.remove :redemption_code
    end
  end
end

class CreatePasses < ActiveRecord::Migration
  def change
    create_table :passes do |t|
      t.string :serialNumber
      t.datetime :expiration
      t.string :passTypeIdentifier
      t.references(:purchaser, foreign_key: {to_table: :accounts})
      t.references(:recipient, foreign_key: {to_table: :accounts})
      t.timestamps null: false
    end
  end
end

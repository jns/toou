class CreatePromotions < ActiveRecord::Migration[5.2]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :copy
      t.string :product
      t.integer :value_cents
      t.datetime :end_date
      t.integer :quantity
      t.string :image_url
      t.string :status

      t.timestamps
    end
  end
end

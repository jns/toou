class CreatePhoneNumbers < ActiveRecord::Migration[5.2]
  def change
    
    create_table :countries do |t|
      t.string :name
      t.string :abbreviation
      t.integer :country_code
      t.integer :phone_number_digits_min
      t.integer :phone_number_digits_max
      t.string :area_code_regex
      
      t.index :country_code
      t.index :abbreviation
    end
    
    create_table :phone_numbers do |t|
      t.string :country_code
      t.string :area_code
      t.string :phone_number
      t.references :account
      t.timestamps
      t.index [:country_code, :area_code, :phone_number], name: "primary_index", unique: true
    end
  end
end

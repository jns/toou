class AddCountryToMerchant < ActiveRecord::Migration[5.2]
  def change
    change_table :merchants do |t|
      t.belongs_to :country
    end
    
    reversible do |dir|
      dir.up do 
        us = Country.find_by(abbreviation: "US")
        Merchant.all.each do |m|
          m.update(country: us)
        end
      end 
      
      dir.down do
        # nothing required
      end
    end
  end
end

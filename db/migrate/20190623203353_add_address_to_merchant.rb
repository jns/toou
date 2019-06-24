class AddAddressToMerchant < ActiveRecord::Migration[5.2]

    def change
      change_table :merchants do |t|
        t.string "address1"
        t.string "address2"
        t.string "city"
        t.string "state"
        t.string "zip"
        t.float "latitude"
        t.float "longitude"
      end
    
      reversible do |dir|
      
        dir.up do
          Location.all.each do |loc|
            m = loc.merchant
            m.update(address1: loc.address1, 
                     address2: loc.address2,
                     city: loc.city,
                     state: loc.state,
                     zip: loc.zip, 
                     latitude: loc.latitude,
                     longitude: loc.longitude)
          end
        end
        
        dir.down do
          Merchant.all.each do |m|
            Location.create(address1: m.address1, 
                     address2: m.address2,
                     city: m.city,
                     state: m.state,
                     zip: m.zip, 
                     latitude: m.latitude,
                     longitude: m.longitude,
                     merchant: m)
          end
        end
      end
      
      drop_table "locations" do |t|
        t.string "address1"
        t.string "address2"
        t.string "city"
        t.string "state"
        t.string "zip"
        t.bigint "merchant_id"
        t.float "latitude"
        t.float "longitude"
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.index ["merchant_id"], name: "index_locations_on_merchant_id"
      end
      
    end
end

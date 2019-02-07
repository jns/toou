class CreateProductsMerchantsPromotions < ActiveRecord::Migration[5.2]
  def change
    
    # Orders will have a polymorphic buyable object that can be a promotion or a product
    add_column :passes, :buyable_id, :integer
    add_column :passes, :buyable_type, :string
    
    # Promotions are created by merchants to sell specific products
    create_table :promotions do |t|
      t.string :name
      t.string :copy
      t.string :product
      t.integer :product_id
      t.integer :product_qty
      t.integer :price_cents
      t.datetime :end_date
      t.string :image_url
      t.string :status

      t.timestamps
    end
    
    # Products are TooU items that merchants can price and redeem
    create_table :products do |t|
      t.string :name
      t.string :icon
      t.integer :max_price_cents
      
      t.timestamps
    end
    
    create_table :roles do |t|
      t.string :name
      t.index :name, unique: true
      t.timestamps
    end
    
    create_table :roles_users do |t|
      t.integer :user_id
      t.integer :role_id
      
      t.index [:user_id, :role_id]
    end
    
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.index :username, unique: true
      
      t.timestamps
    end
    
    # Merchants redeem passes and deliver products or promotions
    create_table :merchants do |t|
      t.string :name
      t.string :website
      t.string :phone_number
      t.string :stripe_id
      t.integer :user_id
      
      t.timestamps
    end
    
    # Merchants agree to redeem products at a given price
    create_table :merchant_products do |t|
      t.integer :merchant_id
      t.integer :product_id
      t.integer :price_cents

      t.timestamps
    end
    
    # Merchants have physical locations
    create_table :locations do |t|
      t.string :address1 
      t.string :address2 
      t.string :city 
      t.string :state 
      t.string :zip 
      t.integer :merchant_id 
      t.float :latitude
      t.float :longitude
      
      t.timestamps
    end
  end
end

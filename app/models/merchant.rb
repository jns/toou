class Merchant < ApplicationRecord
    
    belongs_to :user
    has_one_attached :logo
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :merchant_pass_queues
    has_many :devices

    scope :enrolled, ->{ where('stripe_id is not null') }
    
    scope :distance_sort, ->(lon, lat) { order("point(latitude, longitude) <@> point(#{lon}, #{lat})") }
    
    before_save do
        if ! self.phone_number.empty?
            self.phone_number = PhoneNumber.new(self.phone_number).to_s
        end
    end
    
    def address 
       "#{address1} #{city}, #{state} #{zip}" 
    end
    
    def add_product(product)
        unless can_redeem_buyable?(product)
            MerchantProduct.create(merchant: self, product: product)
        end
    end
    
    def remove_product(product)
        mp = MerchantProduct.find_by(merchant: self, product: product)
        mp.destroy if mp
    end
    
    def can_redeem?(pass)
       products.member?(pass.buyable) and !user.tester?
    end
    
    def can_redeem_buyable?(buyable)
       products.member?(buyable) 
    end
    
    def enrolled
       stripe_id != nil
    end
    
    def charges
        Pass.where(merchant: self).order(transfer_created_at: :desc).collect{|p| 
            {id: p.id, created_at: p.transfer_created_at, amount_cents: p.transfer_amount_cents}
        }
    end
    
    
    def authorize_device(device_id)
        Device.find_or_create_by(merchant: self, device_id: device_id)
    end
    
    # Deauthorizes the specified device if the device belongs to this user
    # returns true if successful, false otherwise
    def deauthorize_device(device)
        dev = device.is_a?(Device) ? device : Device.find_by(merchant: self, id: device)    
        if dev && dev.merchant === self
            dev.destroy 
            return true
        else
            return false
        end
    end 

    
end

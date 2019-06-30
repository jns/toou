class Merchant < ApplicationRecord
    
    belongs_to :user
    has_many :merchant_products
    has_many :products, through: :merchant_products
    has_many :merchant_pass_queues
    has_many :devices

    scope :enrolled, ->{ where('stripe_id is not null') }
    
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
        Pass.where(merchant: self).collect{|p| 
            {id: p.id, created_at: p.transfer_created_at, amount_cents: p.transfer_amount_cents}
        }
    end
    
        # Generates a single use passcode for 
    # The provided device 
    def generate_otp_for_device(device)
        dev = device.is_a?(Device) ? device : Device.find_or_create_by(device_id: device)
        if dev.merchant and dev.merchant != self
            raise "Device in use by another user"
        else
            devices << dev
        end
        
        otp = if user.tester? 
           User::TEST_PASSCODE 
        else
            rand(100000...999999).to_s
        end
        
        dev.password = otp
        dev.password_validity = Time.new + 10.minutes
        
        if dev.save
            otp
        else
            raise "Error generating password"
        end 
    end
    
            
    def authenticate_device(device, passcode) 
        
        dev = device.is_a?(Device) ? device : Device.find_by(device_id: device)
        if devices.member?(dev)
            dev.authenticate(passcode) and dev.password_is_valid?
        else
            false
        end
    end
    
    # Deauthorizes the specified device if the device belongs to this user
    # returns true if successful, false otherwise
    def deauthorize_device(device)
        dev = device.is_a?(Device) ? device : Device.find_by(device_id: device)    
        if dev and dev.merchant and dev.merchant === self 
            dev.destroy 
            return true
        else
            return false
        end
    end 

    
end

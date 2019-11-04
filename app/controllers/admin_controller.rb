class AdminController < ApplicationController

    layout 'admin'
    
    before_action :authorize_admin
    
    def index
        
        now = Time.now.in_time_zone("Pacific Time (US & Canada)").end_of_day
        today = now.to_date
        # Beginning of day
        bod = now.beginning_of_day
        # Day of week
        wday = now.wday
        # Beginning of week
        bow = bod - wday.days
        
        @new_accounts_today = Account.where(created_at: bod..now).count
        @new_accounts_week = Account.where(created_at: bow..now).count
        @accounts_total = Account.count
        
        @new_orders_today = Order.where(created_at: bod..now).count
        @new_orders_week = Order.where(created_at: bow..now).count
        @orders_total = Order.count
        
        @redemptions_today = Pass.where(transfer_created_at: bod..now).count
        @redemptions_week = Pass.where(transfer_created_at: bow..now).count
        @redemptions_total = Pass.count(:transfer_stripe_id)
        
        @merchants_today = Merchant.where(created_at: bod..now).count
        @merchants_week = Merchant.where(created_at: bow..now).count
        @merchants_total = Merchant.count
        
        transfers = Pass.sum(:transfer_amount_cents)
        commitments = Order.sum(:commitment_amount_cents)
        @commitments = "$%0.2f" % ((commitments - transfers)/100.0)
        
        @revenue_today = "$%0.2f" % Order.where(created_at: bod..now).inject(0.0) {|sum, o| sum += o.fee/100.0}
        @revenue_week = "$%0.2f" % Order.where(created_at: bow..now).inject(0.0) {|sum, o| sum += o.fee/100.0}
        @revenue_total = "$%0.2f" % Order.where('charge_amount_cents is not null AND commitment_amount_cents is not null').inject(0.0) {|sum, o| sum += o.fee/100.0}

    end

    private 
    
    def authorize_admin
        unless @current_user and @current_user.admin?
            flash[:notice] = "Administrative access prohibitied"
            redirect_to(login_path)
        end
    end
end

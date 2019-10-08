class AdminController < ApplicationController

    layout 'admin'
    
    before_action :authorize_admin
    
    def index
        
        today = Date.today
        @new_accounts = Account.select("date(created_at)").group("date(created_at)").count
        @new_accounts_today = @new_accounts[today] || 0
        @new_accounts_yesterday = @new_accounts[today - 1.day] || 0
        @accounts_total = Account.count
        
        @new_orders = Order.select("date(created_at)").group("date(created_at)").count
        @new_orders_today = @new_orders[today] || 0
        @new_orders_yesterday = @new_orders[today - 1.day] || 0
        @orders_total = Order.count
        
        @redemptions = Pass.select("date(transfer_created_at)").group("date(transfer_created_at)").count
        @redemptions_today = @redemptions[today] || 0
        @redemptions_yesterday = @redemptions[today - 1.day] || 0
        @redemptions_total = Pass.count(:transfer_stripe_id)
        
        @merchants_today = Merchant.where("created_at > '#{today} 00:00'").count
        @merchants_yesterday = Merchant.where("created_at > '#{today - 1.day} 00:00'").count - @merchants_today
        @merchants_total = Merchant.count
        transfers = Pass.sum(:transfer_amount_cents)
        commitments = Order.sum(:commitment_amount_cents)
        @commitments = "$%0.2f" % ((commitments - transfers)/100.0)
        
        @revenue_today = "$%0.2f" % Order.today.inject(0.0) {|sum, o| sum += o.fee/100.0}
        @revenue_yesterday = "$%0.2f" % Order.yesterday.inject(0.0) {|sum, o| sum += o.fee/100.0}
        @revenue_total = "$%0.2f" % Order.where('charge_amount_cents is not null AND commitment_amount_cents is not null').inject(0.0) {|sum, o| sum += o.fee/100.0}

    end

    private 
    
    def authorize_admin
        begin
            authorize :admin
        rescue
            flash[:notice] = "Administrative access prohibitied"
            redirect_to(login_path)
        end
    end
end

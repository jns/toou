# 
# Command to request valid passes for a account.  By 
# default no used or expired passes are returned.
#
# Takes an optional list of pass serial numbers
# to include in the result set even if expired or used.
# Invalid passes will be returned with an invalid status only.
# 
class RequestPasses

    prepend SimpleCommand
    
    # Initalize the command for a specific account
    def initialize(account, passes = [])
        @account = account
        @passes = passes
    end
    
    def call 
        
        unless @account and @account.is_a? Account
            errors.add(:account, "Invalid account") 
            return
        end
        
        @account.passes.order(created_at: :desc).collect{|p| p}.concat( @passes.map { |sn| 
            found_pass = Pass.find_by(serial_number: sn, account_id: @account.id)
            if found_pass then
                found_pass
            else
                InvalidPass.new(sn)
            end
        }).uniq{|p| p.serial_number}.sort{|a,b| b.expiration <=> a.expiration}
        
    end
    
end

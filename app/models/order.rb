class Order < ActiveRecord::Base
    belongs_to :account
    has_many :passes
    
    def recipients 
       passes.collect{|p| p.account} 
    end
end

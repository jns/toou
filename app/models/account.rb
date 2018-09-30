class Account < ActiveRecord::Base
    has_many :passes
    has_many :orders
end

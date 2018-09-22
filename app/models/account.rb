class Account < ActiveRecord::Base
    has_many :passes
end

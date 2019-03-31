class Device < ApplicationRecord
	has_secure_password
    belongs_to :user
end

class MerchantPolicy < ApplicationPolicy

	# MerchantController Policies
	def index?
		user.merchant?	
	end

	def create?
		if user 
			user.merchant?
		else
			false
		end
	end
	
	def show?
		record.user === user	
	end
	
	def edit?
		record.user === user	
	end
	
	def update?
		record.user === user	
	end
	
	
	def update_products?
		record.user === user	
	end
	
	def enroll?
		true	
	end
	
	def stripe_dashboard_link?
		if user
			record.user === user
		else
			false
		end
	end
	
	# MerchantApiController Policies
	
	def authorize_device?
		user.merchant? && record.user === user	
	end 
	
	def deauthorize_device?
		user.merchant? && record.user === user	
	end
	
	def authorized_devices?
		user.merchant? && record.user === user	
	end 
	
	def stripe_link?
		user.merchant? && record.user === user	
	end 
	
	def merchant? 
		user.merchant? and record.user === user	
	end
	
	def products? 
		user.merchant? and record.user === user	
	end 
	
	def credits?
		if user.is_a? User
			user.merchant? and record.user === user
		elsif user.is_a? Device
			user.merchant === record
		else
			false
		end
	end

	def stripe_link?
		user.merchant? and record.user === user
	end

	# Redemption API Controller Policies
		
	
	# Called by an authorized device seeking information about owning merchant
    def merchant_info? 
		user.is_a? Device and user.merchant === record    
    end


	class Scope < Scope
		def resolve
			scope.where(user: user)
		end
	end
end
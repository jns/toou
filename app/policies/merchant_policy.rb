class MerchantPolicy < ApplicationPolicy

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
	
	def credits?
		user.merchant? and record.user === user
	end
	
	def redeem?
		user.merchant? and record.user === user	
	end
	
	class Scope < Scope
		def resolve
			scope.where(user: user)
		end
	end
end
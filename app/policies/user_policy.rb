class UserPolicy < ApplicationPolicy

	def new?
		true
	end

	def login?
		true
	end

	class Scope < Scope
		def resolve
			if user.admin?
				scope.all
			else
				scope.where(id: user.id)	
			end
		end
	end
end
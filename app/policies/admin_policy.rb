class AdminPolicy < ApplicationPolicy

	def index?
		user and user.admin?	
	end
	
	  
  def show?
    user and user.admin?
  end
  
  def edit?
    false
  end
  
  def destroy?
    false
  end
  
  def update?
    false
  end
  
  def new?
    false
  end
  
  class Scope < Scope
    def resolve
      if user and user.admin?
        scope.all
      else
        []
      end
    end
  end

end
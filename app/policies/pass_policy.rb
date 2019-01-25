class PassPolicy < ApplicationPolicy
  
  def index?
    user ? true : false
  end
  
  def show?
    user ? true : false
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
      scope.all
    end
  end
end

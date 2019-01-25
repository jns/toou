class CardPolicy < ApplicationPolicy
  
  def new?
    user ? true : false
  end
  
  def create?
    user ? true : false
  end
  
  def show?
    user ? true : false
  end 
  
  def update?
    user ? true : false
  end
  
  def edit?
    user ? true : false
  end 
  
  def index?
    user ? true : false
  end
  
  def destroy?
    user ? true : false
  end 
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

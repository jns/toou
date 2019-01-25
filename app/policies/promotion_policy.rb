class PromotionPolicy < ApplicationPolicy
  
  # Promotions are indexable
  def index?
    true
  end
  
  # Authenticated users can create promotions
  def new?
    user ? true : false
  end
  
  # Authenticated users can create promotions
  def create?
    user ? true : false
  end
  
  # Active promotions are visible to anyone
  # Authenticated users can see draft and closed promotions
  def show?
    if user
      true
    else
      record.can_purchase?
    end
  end
  
  # Authenticated users can edit and update draft promotions
  def edit?
    user and record.is_draft?
  end
  
  
  # Authenticated users can edit and update draft promotions
  def update?
    user and record.is_draft?
  end
  
  # Authenticated users can destroy draft promotions
  def destroy?
    user and record.is_draft?
  end
  
  class Scope < Scope
    def resolve
      if user
        scope.all
      else
        scope.where(status: Promotion::ACTIVE)
      end
    end
  end
end

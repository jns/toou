class GroupPolicy < ApplicationPolicy


    class Scope < Scope
        def resolve 
           scope.where(private: false)
        end
    end
    
end
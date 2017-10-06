class IssuePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    !user.has_role?(:manager)
  end

  def update?
    !user.has_role?(:manager)
  end

  def destroy?
    !user.has_role?(:manager)
  end
end

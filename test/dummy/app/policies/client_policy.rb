class ClientPolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin?
  def destroy? = update?

  def permitted_attributes
    [:name, :owner_id]
  end

  class Scope < Scope
    def resolve = (admin? ? scope.all : scope.where(owner: user)).create_with(owner: user)
  end
end

class UserPolicy < ApplicationPolicy
  def show?   = true
  def index?  = true
  def create? = true
  def update? = user.id == record.id

  def permitted_attributes
    [:username]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

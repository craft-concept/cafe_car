class UserPolicy < ApplicationPolicy
  def show?   = true
  def index?  = true
  def create? = true
  def update? = user.id == object.id

  def title_attribute = :username

  def permitted_attributes
    [:username, :password, :password_confirmation]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

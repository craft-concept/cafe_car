class UserPolicy < ApplicationPolicy
  def show?   = true
  def index?  = true
  def create? = true
  def update? = object == user

  def title_attribute = :username

  def permitted_attributes
    [:username,
     *(%i[password password_confirmation] if object == user)
    ]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

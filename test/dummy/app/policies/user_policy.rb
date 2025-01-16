class UserPolicy < ApplicationPolicy
  def show?   = true
  def index?  = true
  def create? = true
  def update? = object == user

  def title_attribute = :name

  def permitted_attributes
    [:name,
     *(%i[password password_confirmation] if object.new_record? or object == user)
    ]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

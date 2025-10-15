class UserPolicy < ApplicationPolicy
  def show?    = true
  def index?   = true
  def create?  = true
  def update?  = me?
  def destroy? = false

  def me? = object == user

  def title_attribute = :name

  def permitted_attributes
    if object.new_record? or me?
      [:name, :avatar, :password, :password_confirmation]
    else
      [:name, :avatar]
    end
  end

  class Scope < Scope
    def resolve = user.super? ? scope.all : scope.where(id: user.id)
  end
end

class UserPolicy < ApplicationPolicy
  def show?    = true
  def index?   = true
  def create?  = true
  def update?  = me?
  def destroy? = false

  def me? = object == user

  def title_attribute = :name

  def permitted_attributes
    [:name,
     *([:password, :password_confirmation] if object.new_record? or me?)
    ]
  end

  class Scope < Scope
    def resolve = user.super? ? scope.all : scope.where(id: user.id)
  end
end

class UserPolicy < ApplicationPolicy
  def show?    = true
  def index?   = true
  def create?  = true
  def update?  = me?
  def destroy? = admin? && !me?

  def me? = object == user

  def title_attribute = :name

  # Narrowed filter list — the policy is the source of truth: the panel
  # enumerates only these (email intentionally off), and Controller::Filtering
  # drops URL keys outside it. Exercises policy narrowing in tests + demo.
  def permitted_filters = %i[name created_at]

  def permitted_attributes
    if object.try(:new_record?) or me?
      [ :name, :email, :avatar, :documents, :password, :password_confirmation ]
    else
      [ :name, :email, :avatar ]
    end
  end

  class Scope < Scope
    def resolve = user&.super? ? scope.all : scope.where(id: user&.id)
  end
end

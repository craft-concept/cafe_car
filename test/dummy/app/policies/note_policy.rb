class NotePolicy < ApplicationPolicy
  def index?   = false
  def show?    = admin?
  def create?  = admin? && policy(object.notable).show?
  def update?  = admin? || object.author == user
  def destroy? = update?


  def permitted_attributes
    [:body, :notable_id, :notable_type]
  end

  class Scope < Scope
    def resolve = scope.create_with(author: user)
  end
end

class NotePolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin? && (object.is_a?(Class) || policy(object.notable).show?)
  def update?  = admin? || object.author == user
  def destroy? = update?


  def permitted_attributes
    [:body, :notable_id, :notable_type]
  end

  class Scope < Scope
    def resolve = scope.create_with(author: user)
  end
end

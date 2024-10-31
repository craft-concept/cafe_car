class UserPolicy < ApplicationPolicy
  def index?  = true
  def create? = true
  def update? = user.id == record.id

  def permitted_attributes
    [:title, :body, :author_id]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

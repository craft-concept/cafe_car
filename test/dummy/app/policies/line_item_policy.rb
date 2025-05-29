class LineItemPolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin?
  def destroy? = update?


  def title_attribute = :amount

  def permitted_attributes
    [:price, :quantity, :description]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

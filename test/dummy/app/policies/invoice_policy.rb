class InvoicePolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin? || object.sender == user
  def destroy? = update?

  def title_attribute = :number

  def permitted_attributes
    [:sender_id, :client_id, :number, :total, :issued_on, :note]
  end

  class Scope < Scope
    def resolve = scope.create_with(issued_on: Date.today, sender: user)
  end
end

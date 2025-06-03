class InvoicePolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin? || object.sender == user
  def destroy? = update?

  def title_attribute = :number

  def permitted_attributes
    [*(:client_id if object.new_record?), :number, :issued_on, :note, line_items: policy(LineItem).permitted_attributes]
  end

  class Scope < Scope
    def resolve = scope.create_with(issued_on: Date.today, sender: user)
  end
end

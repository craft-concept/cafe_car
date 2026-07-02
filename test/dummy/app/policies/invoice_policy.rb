class InvoicePolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin? || object.sender == user
  def destroy? = update?

  def title_attribute = :number

  def permitted_attributes
    # Rails' `fields_for` submits nested associations under `<assoc>_attributes`,
    # and `allow_destroy: true` needs `:id` (to target existing rows) + `:_destroy`
    # permitted — not the bare `line_items:` a scalar-only permit would use.
    [ *(:client_id if object.new_record?), :number, :issued_on, :note,
      line_items_attributes: [ :id, :_destroy, *policy(LineItem).permitted_attributes ] ]
  end

  class Scope < Scope
    def resolve = scope.create_with(issued_on: Date.today, sender: user)
  end
end

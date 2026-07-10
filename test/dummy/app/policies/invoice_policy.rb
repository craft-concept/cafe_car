class InvoicePolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin? || object.sender == user
  def destroy? = update?

  def title_attribute = :number

  # Nested-association filters: an invoice may be filtered by its client's status
  # (a nested enum) and its client's owner (a nested belongs_to). Declaring the
  # dot-path renders the typed control AND whitelists the path — the gate honors
  # `?client.status=` / `?client.owner_id=` and drops any undeclared deeper path.
  def permitted_filters = [ *super, :"client.status", :"client.owner" ]

  def permitted_attributes
    # Rails' `fields_for` submits nested associations under `<assoc>_attributes`,
    # and `allow_destroy: true` needs `:id` (to target existing rows) + `:_destroy`
    # permitted — not the bare `line_items:` a scalar-only permit would use.
    [ *(:client_id if object.new_record?), :number, :issued_on, :note, :paid,
      line_items_attributes: [ :id, :_destroy, *policy(LineItem).permitted_attributes ] ]
  end

  class Scope < Scope
    def resolve = scope.create_with(issued_on: Date.today, sender: user)
  end
end

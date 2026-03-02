class PaperTrail::VersionPolicy < ApplicationPolicy
  def show?   = !item_policy || item_policy.show?
  def index?  = admin?
  def create? = false
  def update? = false
  def destroy? = false

  def item_policy = policy(object.item)
  def title_attribute = :id

  def permitted_attributes
    []
  end

  class Scope < Scope
    def resolve = scope
  end
end

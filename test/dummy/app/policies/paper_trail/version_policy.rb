class PaperTrail::VersionPolicy < ApplicationPolicy
  delegate :show?, to: :item_policy

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

class ActiveStorage::AttachmentPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def create?  = false
  def update?  = false
  def destroy? = update?

  def permitted_attributes = []
  def displayable_attributes
    super - [:record]
  end
  def listable_attributes
    super - [:record_id]
  end

  class Scope < Scope
    def resolve = scope.all
  end
end

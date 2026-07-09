class ActiveStorage::AttachmentPolicy < ApplicationPolicy
  def index?   = true
  def show?    = true
  def create?  = false
  def update?  = false
  def destroy? = update?

  def permitted_attributes = []
  def displayable_attributes
    super - [ :record ]
  end
  def listable_attributes
    super - [ :record_id ]
  end

  # The filter-sensible subset. A `blob` typeahead is 1:1 noise — and an
  # association control presents its collection's titles, which needs a
  # BlobPolicy this app doesn't define.
  def permitted_filters = %i[name record_type created_at]

  class Scope < Scope
    def resolve = scope.all
  end
end

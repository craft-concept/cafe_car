class CafeCar::Attributes
  attr_reader :user, :object, :permitted

  def initialize(user, object, permitted_attributes)
    @user      = user
    @object    = object
    @permitted = [ *permitted_attributes ]
  end

  def info(method) = CafeCar[:FieldInfo].new(object:, method:)

  # A mutable working copy of the permitted attributes. Cloned so callers can
  # add/remove entries without disturbing the canonical `permitted` list.
  def editable
    @editable ||= @permitted.clone
  end
end

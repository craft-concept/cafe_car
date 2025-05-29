class CafeCar::Attributes
  attr_reader :user, :object, :permitted

  def initialize(user, object, permitted_attributes)
    @user      = user
    @object    = object
    @permitted = [*permitted_attributes]
    process_attributes!
  end

  def info(method) = CafeCar[:FieldInfo].new(object:, method:)

  def editable
    @editable ||= @permitted.map()
  end


  private

  def process_attributes!
    @editable = @permitted.clone
  end
end

class CafeCar::Filter::FieldInfo < CafeCar[:FieldInfo]
  def i18n(key, **opts)
    I18n.t(@method, scope: [ :helpers, :filter, key, i18n_key ], raise: true, **opts)
  rescue I18n::MissingTranslationData
  end

  # An accepts_nested_attributes association is still just an association to
  # filter by — the :nested type only matters to edit forms (fields_for).
  def nested_attributes_type = nil

  # Enum choices are the enum keys — the URL carries the readable key
  # (`?status=archived`); QueryBuilder#parse_value passes enum keys through
  # untouched and ActiveRecord casts them to the stored value.
  def choices = values

  # Types filtered by a min/max control pair (see _range_filter).
  def range? = type.in?(%i[integer decimal float date datetime])

  # Attributes the panel renders no control for: file attachments, rich text
  # (keyword search already covers body text), polymorphic targets (no single
  # collection to enumerate), and write-only password fields.
  def unfilterable? = attachment? || rich_text? || polymorphic? || password?

  def input
    case type
    when :string, :text         then :text_field
    when :integer               then :number_field
    when :decimal, :float       then :number_field
    when :date, :datetime       then :date_field
    when :enum                  then :enum
    when :boolean               then :select
    when :password              then :password_field
    when :belongs_to, :has_many then :association
    when :has_one
      rich_text? ? :text_field : nil
    else raise "Missing input type for #{model_name}##{@method} of type :#{type}"
    end
  end
end

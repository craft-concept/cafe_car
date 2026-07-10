class CafeCar::Filter::FieldInfo < CafeCar[:FieldInfo]
  def i18n(key, **opts)
    I18n.t(@method, scope: [ :helpers, :filter, key, i18n_key ], raise: true, **opts)
  rescue I18n::MissingTranslationData
  end

  # A nested filter names a dot-path (`client.status`, `client.owner_id`) — the
  # panel's control still posts the full path, but the TYPE that picks its control
  # comes from the terminal attribute on the far model. `#terminal` is that far
  # FieldInfo, reached by walking the leading association hops; the three data
  # sources a control needs (type, enum values, reflection) delegate to it, so a
  # nested belongs_to renders the same select as a top-level one, a nested enum
  # the same enum select, etc. Labels/placeholders stay on the dotted path so they
  # read disambiguated ("Client status"). `#method` keeps the dotted key, so every
  # `_*_filter` partial names the control with the exact param the gate consumes.
  def nested? = @method.to_s.include?(".")

  def terminal
    @terminal ||= begin
      *hops, leaf = @method.to_s.split(".")
      far = hops.reduce(@model) { |klass, hop| klass.reflect_on_association(hop).klass }
      self.class.new(model: far, method: leaf)
    end
  end

  def type       = nested? ? terminal.type       : super
  def values     = nested? ? terminal.values     : super
  def reflection = nested? ? terminal.reflection : super

  # The submitted field name for the terminal control. A nested belongs_to posts
  # the far foreign key under the full path (`client.owner` declared → the select
  # posts `client.owner_id`); every other nested control posts the path itself.
  def input_key
    return super unless nested?
    *hops, _leaf = @method.to_s.split(".")
    type == :belongs_to ? [ *hops, terminal.reflection.foreign_key ].join(".") : @method.to_s
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

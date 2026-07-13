module CafeCar::Controller::AssociationAuthorization
  private

  # A parent policy controls whether an association key is editable; the
  # associated model's policy scope controls WHICH records may be assigned.
  # Enforce both halves server-side so a crafted foreign key cannot select a
  # row the association typeahead and initial options correctly hide.
  def authorize_association_attributes!(record, policy, attributes)
    checked = {}

    attributes.each_key do |key|
      info       = CafeCar[:FieldInfo].new(model: record.class, method: key)
      reflection = info.reflection
      next unless reflection
      next if info.attachment?

      if info.type == :nested
        authorize_nested_associations!(record, reflection, attributes[key])
      elsif reflection.polymorphic?
        next if checked[reflection.name]
        checked[reflection.name] = true
        authorize_polymorphic_association!(record, policy, reflection, attributes)
      elsif reflection.macro.in?(%i[belongs_to has_many])
        authorize_association_ids!(record, policy, reflection, attributes[key])
      end
    end
  end

  def authorize_nested_associations!(record, reflection, value)
    nested_attributes(reflection, value).each do |attributes|
      next if destroy_nested_record?(attributes)

      nested = nested_record(record, reflection, attributes)
      authorize_association_attributes!(nested, policy(nested), attributes)
    end
  end

  def authorize_polymorphic_association!(record, policy, reflection, attributes)
    id   = attributes[reflection.foreign_key]
    type = attributes[reflection.foreign_type]
    return if id.blank? && type.blank?

    deny_association!(record, policy, reflection) if id.blank? || type.blank?

    klass = record.class.polymorphic_class_for(type)
    deny_association!(record, policy, reflection) unless klass <= ActiveRecord::Base
    authorize_association_ids!(record, policy, reflection, id, klass:)
  rescue NameError, ArgumentError, Pundit::NotDefinedError
    deny_association!(record, policy, reflection)
  end

  def authorize_association_ids!(record, policy, reflection, value, klass: reflection.klass)
    ids = Array.wrap(value).compact_blank.map(&:to_s).uniq
    ids -= existing_association_ids(record, reflection, klass, ids)
    return if ids.empty?

    authorize klass, :index?
    scope   = policy_scope(klass)
    primary = klass.primary_key
    allowed = scope.where(primary => ids).pluck(primary).map(&:to_s)
    deny_association!(record, policy, reflection) unless (ids - allowed).empty?
  rescue Pundit::NotDefinedError
    deny_association!(record, policy, reflection)
  end

  def existing_association_ids(record, reflection, klass, ids)
    return [] unless record.persisted?

    if reflection.polymorphic?
      type = record.public_send(reflection.foreign_type)
      return [] unless type && record.class.polymorphic_class_for(type) == klass
    end

    if reflection.belongs_to?
      [ record.public_send(reflection.foreign_key).to_s ]
    else
      primary = klass.primary_key
      record.association(reflection.name).scope.where(primary => ids).pluck(primary).map(&:to_s)
    end
  rescue NameError, ArgumentError
    []
  end

  def nested_attributes(reflection, value)
    values = value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
    return Array.wrap(values).compact unless reflection.collection?

    values.is_a?(Hash) ? values.values.compact : Array.wrap(values).compact
  end

  def nested_record(record, reflection, attributes)
    attributes = attributes.with_indifferent_access
    id         = attributes[reflection.klass.primary_key]
    return reflection.klass.new unless id

    association = record.association(reflection.name)
    if reflection.collection?
      association.scope.find_by(reflection.klass.primary_key => id)
    else
      association.target if association.target&.id.to_s == id.to_s
    end || reflection.klass.new
  end

  def destroy_nested_record?(attributes)
    value = attributes.respond_to?(:[]) && (attributes[:_destroy] || attributes["_destroy"])
    ActiveModel::Type::Boolean.new.cast(value)
  end

  def deny_association!(record, policy, reflection)
    raise Pundit::NotAuthorizedError.new(
      query: "associate_#{reflection.name}?", record:, policy:
    )
  end
end

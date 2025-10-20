module CafeCar::Policy
  extend ActiveSupport::Concern

  def policy(object) = Pundit.policy(user, object)

  def model
    @model ||= object.try(:klass) or object.is_a?(Class) ? object : object.class
  end

  def info(method)
    @info         ||= {}
    @info[method] ||= CafeCar[:FieldInfo].new(model:, method:)
  end

  def title_attribute
    @title_attribute ||= displayable_attributes.first
  end

  def logo_attribute
    model.info.fields.listable.attachments.first&.method
  end

  def listable_attributes
    model.info.fields.listable.map(&:method)
  end

  def displayable_attributes
    permitted_attribute_keys
      .union(model.columns.map(&:name).map(&:to_sym))
      .map    { association_for_attribute(_1) || _1 }
      .reject { filtered_attribute? _1 } - %i[id]
  end

  def permitted_fields
    @permitted_fields ||= permitted_attribute_keys.map { info _1 }
  end

  def editable_attributes
    permitted_fields.map(&:input_key) - permitted_fields.flat_map(&:abrogated_keys)
  end

  def displayable_associations
    model.reflections.values
         .select {|a| !a.options[:autosave] && !a.options[:polymorphic] }
         .reject { _1.class_name =~ /^ActiveStorage::/ }
         .map    { _1.name.to_sym }
  end

  def permitted_attribute_keys
    permitted_attributes.flat_map {|a| a.try(:keys) || a }
  end

  def permitted_association?(name)
    ref = model.reflect_on_association(name)

    return false if ref.has_one?
    return permitted_attribute?(ref.foreign_key) if ref.belongs_to?

    permitted_attribute?("#{ref.name.to_s.singularize}_ids")
  end

  def filtered_attribute?(attribute)
    model.inspection_filter.filter_param(attribute, nil).present?
  end

  def permitted_attribute?(attribute)
    permitted_attribute_keys.include?(attribute.to_sym)
  end

  def displayable_attribute?(attribute)
    displayable_attributes.include?(attribute.to_sym)
  end

  def association_for_attribute(attribute)
    info(attribute).reflection&.name
  end
end

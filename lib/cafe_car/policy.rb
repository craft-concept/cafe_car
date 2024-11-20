module CafeCar::Policy
  extend ActiveSupport::Concern

  def model
    @model ||= object.try(:klass) or object.is_a?(Class) ? object : object.class
  end

  def info(method)
    @info         ||= {}
    @info[method] ||= CafeCar[:FieldInfo].new(object:, method:)
  end

  def title_attribute
    @title_attribute ||= displayable_attributes.first
  end

  def displayable_attributes
    permitted_attribute_keys
      .union(model.columns.map(&:name).map(&:to_sym))
      .map { association_for_attribute(_1) || _1 }
      .reject { filtered_attribute? _1 } - %i[id]
  end

  def editable_attributes
    permitted_attribute_keys.map { association_for_attribute(_1) || _1 }
  end

  def displayable_associations
    model.reflections.values.
      select {|a| !a.options[:autosave] && !a.options[:polymorphic] }.
      map(&:name).map(&:to_sym) - %i[base_tags taggings tag_taggings]
  end

  def editable_associations
    displayable_associations.select {|a| permitted_association?(a) }
  end

  def reflect_on_editable_associations
    model.reflections.slice(*editable_associations.map(&:to_s)).values
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

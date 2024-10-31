module CafeCar::Policy
  extend ActiveSupport::Concern

  def model
    record.try(:model) or record.is_a?(Class) ? record : record.class
  end

  def displayable_attributes
    ids = %w[id]
    model.columns.
      map(&:name).
      reject {|c| ids.include?(c) || c.ends_with?('_id') }.
      map(&:to_sym)
  end

  def editable_attributes
    permitted_attribute_keys.grep_v(/_ids?$/)
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

  def permitted_attribute?(attribute)
    permitted_attribute_keys.include?(attribute.to_sym)
  end
end

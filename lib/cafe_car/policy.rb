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

  # The bulk actions offered on this model's index table — the policy is the source
  # of truth. Each name maps to a policy predicate (`name?`, authorized per record
  # in Controller#batch) and a model bang method (`name!`, applied to each). Ships
  # with `:destroy`; a host lists its own (e.g. `%i[publish destroy]`) by overriding
  # this, with no registration anywhere else. Return `[]` to offer none.
  def permitted_bulk_actions = %i[destroy]

  # The metrics the dashboard renders for this model by default — the same
  # policy-is-source-of-truth pattern as #permitted_bulk_actions. Each name is a
  # model scope (`:all` = the whole relation) whose row count becomes a tile; the
  # `metrics` view helper reads this list. Empty by default (opt in per model).
  def permitted_metrics = []

  # The attributes (columns and associations) a user may filter an index by —
  # the same policy-is-source-of-truth pattern: the filter UI enumerates this
  # list, and Controller::Filtering drops URL filter keys that aren't on it.
  # Defaults to #displayable_attributes (Rails' parameter filter already strips
  # password/token columns); a host overrides this to narrow or widen the list.
  def permitted_filters = displayable_attributes

  # The named model scopes invokable as URL filter params — `?published=true`
  # calls the `published` scope. Empty by default (opt in per model): a scope
  # key reaches `QueryBuilder#scope!`, which can invoke any public class method
  # with a URL-supplied argument, so a host lists the safe ones explicitly.
  def permitted_scopes = []

  # Is `attribute` filterable? Checks #permitted_filters on the base name — a
  # foreign key resolves to its association (`client_id` → `:client`), matching
  # how #displayable_attributes lists it.
  def permitted_filter?(attribute)
    attribute = attribute.to_sym
    permitted_filters.include?(association_for_attribute(attribute) || attribute)
  end

  def permitted_scope?(name) = permitted_scopes.include?(name.to_sym)

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
         .select { |a| !a.options[:autosave] && !a.options[:polymorphic] }
         .reject { _1.class_name =~ /^ActiveStorage::/ }
         .map    { _1.name.to_sym }
  end

  def permitted_attribute_keys
    permitted_attributes.flat_map { |a| a.try(:keys) || a }
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

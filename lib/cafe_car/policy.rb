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
    @title_attribute ||= attributes.displayable.first
  end

  # The bulk actions offered on this model's index table — the policy is the source
  # of truth. Each name maps to a policy predicate (`name?`, authorized per record
  # in Controller#batch) and a model bang method (`name!`, applied to each). Ships
  # with `:destroy`; a host lists its own (e.g. `%i[publish destroy]`) by overriding
  # this, with no registration anywhere else. Return `[]` to offer none.
  def permitted_bulk_actions = %i[destroy]

  # The custom actions offered on a single record — rendered on the show page's
  # Actions card and on each index row. Same derivation as
  # #permitted_bulk_actions: the `name?` predicate authorizes and the record's
  # `name!` bang method runs (see Controller#member_action). Empty by default;
  # a host lists its own (e.g. `%i[publish]`) with no registration anywhere else.
  def permitted_member_actions = []

  # The custom actions offered on the whole collection — rendered in the index
  # toolbar. The `name?` predicate authorizes (asked of the model class, not a
  # record) and `name!` runs on the policy scope, which ActiveRecord delegates
  # to a class method (see Controller#collection_action). Empty by default.
  def permitted_collection_actions = []

  # The metrics the dashboard renders for this model by default — the same
  # policy-is-source-of-truth pattern as #permitted_bulk_actions. Each name is a
  # model scope (`:all` = the whole relation) whose row count becomes a tile; the
  # `metrics` view helper reads this list. Empty by default (opt in per model).
  def permitted_metrics = []

  # The attributes (columns and associations) a user may filter an index by —
  # the same policy-is-source-of-truth pattern: the filter UI enumerates this
  # list, and Controller::Filtering drops URL filter keys that aren't on it.
  # Defaults to `attributes.displayable` (Rails' parameter filter already strips
  # password/token columns); a host overrides this to narrow or widen the list.
  def permitted_filters = attributes.displayable

  # The named model scopes invokable as URL filter params — `?published=true`
  # calls the `published` scope. Empty by default (opt in per model): a scope
  # key reaches `QueryBuilder#scope!`, which can invoke any public class method
  # with a URL-supplied argument, so a host lists the safe ones explicitly.
  def permitted_scopes = []

  # Is `attribute` filterable? Checks #permitted_filters on the base name — a
  # foreign key resolves to its association (`client_id` → `:client`), matching
  # how `attributes.displayable` lists it.
  def permitted_filter?(attribute)
    attribute = attribute.to_sym
    permitted_filters.include?(association_for_attribute(attribute) || attribute)
  end

  def permitted_scope?(name) = permitted_scopes.include?(name.to_sym)

  def logo_attribute
    model.info.fields.listable.attachments.first&.method
  end

  def permitted_fields
    @permitted_fields ||= permitted_attribute_keys.map { info _1 }
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
    attributes.displayable.include?(attribute.to_sym)
  end

  def association_for_attribute(attribute)
    info(attribute).reflection&.name
  end
end

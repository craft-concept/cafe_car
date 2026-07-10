# The policy's attribute sets — the single surface for "which attributes does
# this policy expose, and how." Mirrors the nested Scope: a policy builds one
# (`policy.attributes`) and reads `.listable`, `.displayable`, `.editable`,
# `.filterable`, and `.actions` through it. Every reader derives from the
# policy's host-overridable declarations (`permitted_attributes`,
# `permitted_filters`, `permitted_*_actions`), so a host override of any of
# those flows through unchanged.
class CafeCar::Attributes
  def initialize(policy)
    @policy = policy
  end

  # Columns an index table shows by default — the model's listable fields.
  def listable = model.info.fields.listable.map(&:method)

  # Columns/associations shown on a record and the default filter set: the
  # permitted attribute keys unioned with the model's own columns, each foreign
  # key resolved to its association, parameter-filtered keys (password/token)
  # and `id` dropped.
  def displayable
    permitted_attribute_keys
      .union(model.columns.map(&:name).map(&:to_sym))
      .map    { association_for_attribute(_1) || _1 }
      .reject { filtered_attribute? _1 } - %i[id]
  end

  # Form input keys for the permitted attributes, minus keys a richer input
  # abrogates (a file field replaces its `*_cache`, a nested field its ids).
  def editable
    permitted_fields.map(&:input_key) - permitted_fields.flat_map(&:abrogated_keys)
  end

  # The attributes an index may be filtered by — the policy's `permitted_filters`
  # (which defaults to #displayable). Host-overridable on the policy.
  def filterable = @policy.permitted_filters

  # The custom actions this policy declares, grouped by target.
  def actions = Actions.new(@policy)

  # Reads the policy's three host-overridable action lists through one object.
  Actions = Struct.new(:policy) do
    def member     = policy.permitted_member_actions
    def collection = policy.permitted_collection_actions
    def bulk       = policy.permitted_bulk_actions
  end

  private

  delegate :model, :permitted_attribute_keys, :permitted_fields,
           :association_for_attribute, :filtered_attribute?, to: :@policy
end

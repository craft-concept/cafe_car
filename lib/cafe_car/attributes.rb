# The policy's attribute sets — the single surface for "which attributes does
# this policy expose, and how." Mirrors the nested Scope: a policy builds one
# (`policy.attributes`) and reads `.listable`, `.displayable`, `.editable`,
# `.filterable`, and `.actions` through it. Every reader derives from the
# policy's host-overridable declarations (`displayable_attributes`,
# `listable_attributes`, `permitted_attributes`, `permitted_filters`, and
# `permitted_*_actions`), so a host override of any of those flows through
# unchanged.
class CafeCar::Attributes
  def initialize(policy)
    @policy = policy
  end

  # Columns an index table shows by default. Host-overridable on the policy.
  def listable = @policy.listable_attributes

  # Columns/associations shown on a record and the default filter set: the
  # permitted attribute keys unioned with the model's own columns, each foreign
  # key resolved to its association, parameter-filtered keys (password/token)
  # and `id` dropped.
  def displayable = @policy.displayable_attributes

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

  delegate :permitted_fields, to: :@policy
end

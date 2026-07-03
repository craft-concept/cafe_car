module CafeCar
  # A named operation the index table applies to many records at once. Each
  # selected record is authorized on its own — `query` is the policy predicate a
  # record must answer true (a record the user can't `query?` is skipped, never
  # bulk-bypassed) — and `apply` mutates one record. The default `apply` calls the
  # matching bang method, so `bulk_action(:destroy)` maps to `record.destroy!`.
  class BulkAction
    attr_reader :name, :query

    def initialize(name, query: :"#{name}?", &apply)
      @name  = name.to_sym
      @query = query.to_sym
      @apply = apply || ->(record) { record.public_send(:"#{name}!") }
    end

    # Whether `policy` grants this action. Policies that don't define the predicate
    # simply don't offer the action, rather than erroring.
    def allowed?(policy)
      policy.respond_to?(@query) && policy.public_send(@query)
    end

    def apply(record) = @apply.call(record)

    def label = @name.to_s.humanize
  end
end

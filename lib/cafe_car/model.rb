module CafeCar::Model
  extend ActiveSupport::Concern

  include CafeCar::Queryable
  include CafeCar::Informable

  class_methods do
    def sorted(*args)
      keys = args.join(",").split(",").filter_map { normalize_sort_key(_1) }
      keys.empty? ? all : reorder(*keys)
    end

    # Turn one requested sort key into a safe `reorder` argument, or nil to drop
    # it. Honors a leading "-" for descending and validates the column against
    # the model's real columns — so a client-supplied `?sort=` (e.g. `item.` or
    # `bogus.col`) can never reach `reorder` as raw SQL, where it would trip
    # Rails' dangerous-query guard into an unauthenticated 500.
    def normalize_sort_key(key)
      desc   = key.to_s.start_with?("-")
      column = key.to_s.delete_prefix("-").strip
      { column => desc ? :desc : :asc } if column_names.include?(column)
    end
  end
end

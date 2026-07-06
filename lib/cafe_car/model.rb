module CafeCar::Model
  extend ActiveSupport::Concern

  include CafeCar::Queryable
  include CafeCar::Informable

  # A validated sort term: an Arel/hash `order` argument plus the association to
  # `left_outer_joins` (nil for a plain column) so the qualified ORDER BY resolves.
  SortKey = Data.define(:order, :join)

  class_methods do
    def sorted(*args)
      keys = args.join(",").split(",").filter_map { normalize_sort_key(_1) }
      return all if keys.empty?
      scope = reorder(*keys.map(&:order))
      joins = keys.filter_map(&:join).uniq
      joins.any? ? scope.left_outer_joins(*joins) : scope
    end

    # Turn one requested sort key into a safe SortKey, or nil to drop it. Honors a
    # leading "-" for descending. Every key is validated against the model's real
    # columns/associations before it can reach `reorder` — a client-supplied
    # `?sort=` (e.g. `item.`, `bogus.col`, or a raw SQL fragment) can never pass
    # through as SQL, where it would trip Rails' dangerous-query guard into an
    # unauthenticated 500.
    def normalize_sort_key(key)
      desc      = key.to_s.start_with?("-")
      name      = key.to_s.delete_prefix("-").strip
      direction = desc ? :desc : :asc

      if name.include?(".")
        association_sort_key(name, direction)
      elsif column_names.include?(name)
        SortKey.new(order: { name => direction }, join: nil)
      end
    end

    # A `<belongs_to>.<column>` header-sort key (LabelBuilder only emits these for
    # belongs_to). Qualifies the ORDER BY to the *reflected* table so custom table
    # names/aliases work, and joins the association in so the column resolves.
    # Strict: an unknown/polymorphic association or unknown column returns nil.
    def association_sort_key(name, direction)
      assoc, column = name.split(".", 2)
      reflection    = reflect_on_association(assoc.to_sym)
      return unless reflection&.belongs_to? && !reflection.polymorphic?
      return unless reflection.klass.column_names.include?(column)

      order = reflection.klass.arel_table[column].public_send(direction)
      SortKey.new(order:, join: reflection.name)
    end
  end
end

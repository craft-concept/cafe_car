module CafeCar::Queryable
  extend ActiveSupport::Concern

  class_methods do
    def scope(name, body)
      scopes[name] = body
      super
    end

    # A random member of the relation, or nil when it's empty. Backs the
    # `Model.sample or create(:x)` seeding idiom (see test/dummy/factories.rb):
    # pick an existing row, else make one. The guard is load-bearing — on a
    # zero-row table `rand(0)` returns a Float, and `offset(<float>)` is
    # adapter-dependent nonsense, so an empty relation must short-circuit to nil.
    def sample
      return if (n = count).zero?
      offset(rand(n)).first
    end

    def query(params)  = query_builder.query(params).scope
    def query!(params) = query_builder.query!(params).scope

    # Turnkey keyword search: case-insensitive match of `term` across the model's
    # string/text columns. Uses Arel `#matches` so it stays DB-portable (ILIKE on
    # Postgres, LIKE on SQLite/MySQL). Columns the parameter filter hides (passwords,
    # tokens, ...) are skipped, mirroring the policy's displayable guarantee. Hosts
    # that declare their own `scope :search` take precedence (see QueryBuilder#search!).
    def default_search(term)
      columns = searchable_columns
      return none if columns.empty?
      pattern = "%#{sanitize_sql_like(term.to_s)}%"
      where(columns.map { arel_table[_1].matches(pattern) }.reduce(:or))
    end

    def searchable_columns
      columns_hash.values
                  .select { _1.type.in?(%i[string text]) }
                  .map(&:name)
                  .reject { inspection_filter.filter_param(_1, nil).present? }
    end

    def query_builder
      CafeCar::QueryBuilder.new(all)
    end

    def scopes
      @scopes ||= {}.with_indifferent_access
    end

    def local_methods
      @local_methods ||= public_methods -
        ActiveRecord::Base.public_methods -
        Kaminari::ConfigurationMethods::ClassMethods.instance_methods
    end
  end
end

module CafeCar::Queryable
  extend ActiveSupport::Concern

  class_methods do
    def scope(name, body)
      scopes[name] = body
      super
    end

    def sample = offset(rand(count)).first

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

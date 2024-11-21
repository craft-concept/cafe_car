module CafeCar
  class QueryBuilder
    require "activerecord_where_assoc"

    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def unscoped = QueryBuilder.new(@scope.unscoped)

    def arel = @scope.arel_table

    def parse_time(value)
      Chronic.parse(value, guess: false, context: :past)
    rescue NoMethodError
      nil
    end

    def parse_value(key, value)
      case column(key)&.type
      when :datetime
        parse_time(value) || value
      else value
      end
    end

    def update!(&)
      scope  = @scope.instance_exec(@scope, &)
      @scope = scope if scope
      self
    end

    def not!(&)
      inverted = unscoped.instance_exec(&).scope.invert_where
      update! { _1.and(inverted) }
    end

    def column(name)       = @scope.columns_hash[name.to_s]
    def association?(name) = @scope.reflect_on_association(name).present?
    def attribute?(name)   = column(name).present?
    def scope?(name)       = name.intern.in? @scope.local_methods

    def param!(key, value)
      case key
      when /^(.*)!$/
        not! { param!($1, value) }
      when /^(.*)~$/
        param!($1, Regexp.new(value, Regexp::IGNORECASE))
      when method(:association?)
        association!(key, value)
      when method(:attribute?)
        attribute!(key, value)
      when method(:scope?)
        scope!(key, value)
      else
        raise "what is this param? #{key.inspect}"
      end
    end

    def attribute!(key, value)
      case [key, value]
      in _, Regexp
        @scope.where!(arel[key].matches_regexp(value.source, !value.casefold?))
      else @scope.where!(key => parse_value(key, value))
      end
      self
    end

    def association!(name, value, ...)
      update! do
        case value
        when true then  where_assoc_exists(name)
        when false then where_assoc_not_exists(name)
        else            where_assoc_exists(name) { query(value, ...) }
        end
      end
    end

    def scope!(name, value)
      arity = (@scope.scopes[name] || @scope.method(name)).arity
      value = nil if arity == 0 and value == true

      update! { public_send(name, *value) }
    end

    def query!(params = nil)
      params.each { param!(_1, _2) } if params
      self
    end

    def query(...) = update!(&:all).query!(...)
  end
end

# Article.query do
#   published
#   user { username(/bob/) }
#   user.username(/bob/)
# end
#
# Article.query(published: true, user: {username: /bob/})
#
# Article.published(true).where_assoc_exists(:user) { where(username: /bob/) }

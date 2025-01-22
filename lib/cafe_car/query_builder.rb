module CafeCar
  class QueryBuilder
    require "activerecord_where_assoc"

    Op = Struct.new(:op, :rhs) do
      def initialize(op, rhs)
        super(op.to_sym, rhs)
      end

      def flop = op.to_s.tr("<>", "><").to_sym
      def map  = Op.new(op, yield(rhs))

      def arel(node) = node.public_send(arel_op, rhs)

      def arel_op
        case op
        when :<  then :lt
        when :>  then :gt
        when :>= then :gteq
        when :<= then :lteq
        when :== then :eq
        else op
        end
      end
    end

    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def unscoped   = QueryBuilder.new(@scope.unscoped)
    def arel(key)  = @scope.arel_table[chomp(key)]
    def chomp(key) = key.to_s.sub(/\W+$/, '')

    def parse_time(value)
      Chronic.parse(value, guess: false, context: :past)
    rescue NoMethodError
      nil
    end

    def parse_range(key, value)
      Range.new(parse_value(key, value.begin).then { _1.try(:begin) or _1 },
                parse_value(key, value.end).then { value.exclude_end? ? _1.try(:begin) : _1.try(:end) or _1 },
                value.exclude_end?)
    end

    def parse(key, value)
      new_value = parse_value(key, value)
      if new_value != value
        parse(key, new_value)
      else
        new_value
      end
    end

    def parse_value(key, value)
      case value
      in Op(rhs: /^=(.*)$/)
        Op.new("#{value.op}=", $1)
      in Op(op: (:< | :>=), rhs: Range)
        value.map(&:begin)
      in Op(op: (:> | :<=), rhs: Range)
        value.map(&:end)
      in Range
        parse_range(key, value)
      in Array | Op
        value.map { parse_value(key, _1) }
      in "true" then true
      in "false" then false
      in String
        case column(key)&.type || reflection(key)&.macro
        when :datetime then parse_time(value) || value
        when :integer  then value.to_i
        when :float    then value.to_f
        when :belongs_to, :has_many, :has_one
          value.to_i
        else value
        end
      else value
      end
    end

    def update!(&)
      scope  = yield @scope
      @scope = scope if scope
      self
    end

    def not!(&)
      inverted = unscoped.tap { _1.instance_exec(&) }.scope.invert_where
      update! { _1.and(inverted) }
    end

    def column(name)       = @scope.columns_hash[name.to_s]
    def reflection(name)   = @scope.reflect_on_association(name)
    def association?(name) = reflection(name).present?
    def attribute?(name)   = column(name).present?
    def scope?(name)       = name.intern.in? @scope.local_methods

    def arel!(node) = @scope.where!(node)

    def param!(key, value)
      case key
      when /^(.*?)\s*!$/
        not! { param!($1, value) }
      when /^(.*?)\s*~$/
        param!($1, Regexp.new(value, Regexp::IGNORECASE))
      when /^(.*?)\s*([<>]=?)$/
        param!($1, Op.new($2, value))
      when method(:association?)
        association!(key, value)
      when method(:attribute?)
        attribute!(key, value)
      when method(:scope?)
        scope!(key, value)
      else
        raise "can't find #{key.inspect} on #{@scope.model_name}"
      end
    end

    def attribute!(key, value)
      case [key, value]
      in _, Regexp
        @scope.where!(arel(key).matches_regexp(value.source, !value.casefold?))
      in _, Op
        @scope.where!(parse(key, value).arel(arel(key)))
      else @scope.where!(key => parse(key, value))
      end
    end

    def association!(name, value, ...)
      update! do
        case value
        when true  then @scope.where_assoc_exists(name)
        when false then @scope.where_assoc_not_exists(name)
        when Integer, Range, /^\d+$/
          @scope.where_assoc_count(parse(name, value), :==, name)
        when Op
          value = parse(name, value)
          @scope.where_assoc_count(value.rhs, value.flop, name)
        else @scope.where_assoc_exists(name) { all.query!(value, ...) }
        end
      end
    end

    def scope!(name, value)
      value = parse_value(name, value)
      arity = (@scope.scopes[name] || @scope.method(name)).arity
      value = nil if arity == 0 and value == true

      update! { _1.public_send(name, *value) }
    end

    def search!(term)
      @scope.search!(term) if @scope.respond_to?(:search!)
      @scope.query!("body~": term) if @scope < ::ActionText::RichText
      update! { _1.search(term) }
    end

    def query!(params = nil)
      case params
      when Hash  then params.each { param!(_1, _2) }
      when Array then params.each { query! _1 }
      when String then search!(params)
      # when Arel::Nodes::Node then arel!(params)
      when nil
      else raise ArgumentError, "cannot query on #{params}"
      end
      self
    end

    def query(...) = clone.update!(&:all).query!(...)
  end
end

# Article.query do
#   published
#   user { name(/bob/i) }
#   user.name(/bob/i)
# end
#
# Article.query(published: true, user: {name: /bob/i})
#
# Article.published(true).where_assoc_exists(:user) { where(name: /bob/i) }

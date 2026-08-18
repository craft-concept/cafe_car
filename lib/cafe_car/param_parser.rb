class CafeCar::ParamParser
  # Rack's param_depth_limit guards bracket-nesting (a[b][c]) but not this dot
  # scheme, so an attacker-sized ?a.b.c.…=1 key would nest unbounded and
  # overflow the stack. Cap it the way Rails caps param depth (default 100).
  MAX_DEPTH = 100

  def initialize(params)
    @params = params
  end

  def parsed
    @parsed ||= @params.compact_blank
                       .then { params _1 }
  end

  def params(params)
    params.map { |k, v| nest(k.split("."), value(v)) }
          .reduce({}) { _1.deep_merge(_2, &method(:merge)) }
          .with_indifferent_access
  end

  # Fold dotted keys into a nested hash, rejecting a key too deep to be a real
  # filter — a 400, not a 500-deep stack overflow in the host controller.
  def nest(keys, value)
    raise ActionController::BadRequest, "param nesting too deep" if keys.length > MAX_DEPTH
    keys.reverse.reduce(value) { { _2 => _1 } }
  end

  def merge(_, a, b)
    if a.is_a?(Array) || b.is_a?(Array)
      [ *Array.wrap(a), *Array.wrap(b) ]
    else
      b
    end
  end

  def value(v)
    case v
    when Array      then v.map { value(_1) }
    when Hash       then params(v).tap { _1.merge!(_1.delete("")) if _1[""] }
    when '""', "''" then ""
    when "nil", ""  then nil
    when /,/        then value(v.split(","))
    when /^(.*?)\.\.(\.?)(.*)$/
      begin
        Range.new(value($1), value($3), $2.present?)
      rescue ArgumentError
        v
      end
    else v
    end
  end
end

class CafeCar::ParamParser
  def initialize(params)
    @params = params
  end

  def parsed
    @parsed ||= @params.compact_blank
                       .then { params _1 }
  end

  def params(params)
    params.map {|k, v| k.split('.').reverse.reduce(value(v)) { {_2 => _1} } }
          .reduce({}) { _1.deep_merge(_2, &method(:merge)) }
          .with_indifferent_access
  end

  def merge(_, a, b)
    if a.is_a?(Array) || b.is_a?(Array)
      [*Array.wrap(a), *Array.wrap(b)]
    else
      b
    end
  end

  def value(v)
    case v
    when Array      then v.map { value(_1) }
    when Hash       then params(v).tap { _1.merge!(_1.delete("")) if _1[""] }
    when '""', "''" then ''
    when 'nil', ''  then nil
    when /[{}\[\]]/ then value(JSON.parse(v))
    when /,/        then value(v.split(','))
    when /^(.*?)\.\.(\.?)(.*)$/
      begin
        Range.new(value($1), value($3), $2.present?)
      rescue ArgumentError
        v
      end
    when /^\$(\w+)\.(\w+)$/
      # TODO: make less scary
      $1.constantize.arel_table[$2]
    else v
    end
  end
end

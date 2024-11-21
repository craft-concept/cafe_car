class CafeCar::ParamParser
  def initialize(params)
    @params = params
  end

  def params = parsed

  def parsed
    @parsed ||= parse(@params)
  end

  def parse(params)
    params.then { _1.try(:to_unsafe_h) || _1 }
          .select {|k, *| k.include?('.') }
          .map {|k, v| k.split('.').reverse.reduce(value(v)) { {_2 => _1} } }
          .reduce({}) {|prms, p| prms.deep_merge(p, &method(:merge)) }
          .with_indifferent_access
  end

  def merge(_key, a, b)
    if a.is_a?(Array) || b.is_a?(Array)
      [*Array.wrap(a), *Array.wrap(b)]
    else
      b
    end
  end

  def value(v)
    case v
    when Array      then v.map { value(_1) }
    when '""', "''" then ''
    when 'nil', ''  then nil
    when /[{}\[\]]/ then JSON.parse(v)
    when /,/        then value(v.split(','))
    when /^(.*?)\.\.(\.?)(.*)$/
      Range.new(*[$1, $3].map(&:presence).map { value(_1) }, $2.present?)
    when /^\$(\w+)\.(\w+)$/
      $1.constantize.arel_table[$2]
    when Hash
      v.reject {|k, *| k.include?('.') }
       .transform_values { value(_1) }
       .merge(parse(v))
       .tap {|h| h.merge!(h.delete('')) if h.key?('') }
    else v
    end
  end
end

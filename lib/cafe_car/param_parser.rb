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
    when '""', "''"
      ''
    when 'nil', ''
      nil
    when /[{}\[\]]/
      JSON.parse(v)
    when /,/
      value v.split(',')
    when /\.\./
      a, b = v.split('..').map(&:presence).map { value(_1) }
      a..b
    when /^\$(\w+)\.(\w+)$/
      $1.constantize.arel_table[$2]
    when Array
      v.map { value(_1) }
    when Hash
      v.reject {|k, *| k.include?('.') }
       .transform_values { value(_1) }
       .merge(parse(v))
       .tap {|h| h.merge!(h.delete('')) if h.key?('') }
    else
      v
    end
  end
end

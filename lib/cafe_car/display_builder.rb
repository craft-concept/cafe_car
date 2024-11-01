module CafeCar
  class DisplayBuilder
    attr_reader :object

    def initialize(template, object)
      @template = template
      @object   = object
    end

    def title
    end

    def try(*methods)
      # methods.filter_map { @object.try(_1) }
      #        .map { show _1 }
      #        .try { @template.safe_join _1 }
    end

    def show(*methods, try: false)
      # methods.filter_map { @object.public_send(_1) }.map { show _1 }.try { @template.safe_join(}
    end

    def to_s
      case object

      when Symbol
        object.to_s.humanize
      when Integer
        object.to_s
      when Range

      when ApplicationRecord
        begin
          @template.link_to object
        rescue StandardError
          object.to_s
        end
      when Time
        tag.span object.to_formatted_s, title: object.to_formatted_s(:long_ordinal)
      when Date
        tag.span object.to_formatted_s
      when ActiveRecord::Relation
        object = object.to_a.uniq
        object = object.sort_by(&:sort_key) if object.first.respond_to?(:sort_key)
        show object, **options
      when Set
        object.map {|x| show(x) }.join(', ')
      when Hash
        tag.code object.pretty_inspect, class: 'pretty_inspect'
      when Array
        return options[:empty] || '(none)' if object.empty?

        safe_join [
          *([object.size, ' total: '] if options[:count]),
          safe_join(object.map {|v| show(v, **options) }, ', ')
        ].compact

      when %r{^https?://.+\.(png|jpe?g|svg)$}
        image_tag object, style: 'width: 1em'
      when %r{^https?://}
        link_to object, object, target: '_blank', rel: 'noopener'
      else
        if (max_length = options[:truncate]).present?
          tag.span truncated(object, max_length), class: 'tt', title: object
        else
          object
        end
      end
    end
  end
end

def display(*vals, **options)
  capture do
    vals.each do |object|
      concat display_value(object, **options)
    end
  end
end

def display_attributes(record, *methods, **options, &)
  methods = methods.presence

  methods ||=
    case record
    when ApplicationRecord
      policy(record).displayable_attributes
    else
      record.instance_values.keys
    end

  methods -= options[:except] if options[:except]

  capture do
    methods.each do |method|
      concat display_attribute(record, method, **options, &)
    end
  end
end

def display_associations(record)
  case record
  when ApplicationRecord
    attributes = policy(record).displayable_associations.presence
    display_attributes record, *attributes if attributes
  end
end

def display_attribute(record, method, **options, &)
  label   = options.delete(:label) { method.to_s.chomp('_at').humanize }
  map     = options.delete(:map) { :itself }
  empty   = options.delete(:empty) { '(none)' }
  count   = options.delete(:count) { true }
  compact = options.delete(:compact) { false }
  try     = options.delete(:try) { false }

  value = try ? record.try(method) : record.public_send(method) unless record.nil?
  value = map.to_proc.call(value) if map && !value.nil?

  key  = tag.strong(label) if label
  hint = hint_for(record, method) if record

  value =
    if value.nil?
      empty
    elsif block_given?
      capture(value, method, &)
    else
      display_value(value, compact:, count:, **options)
    end

  if compact
    tag.div do
      if key
        concat key
        concat ': '
      end
      concat value
    end
  else
    tag.p do
      if key
        concat key
        concat info(hint) if hint
        concat tag.br
      end
      concat value
    end
  end
end

private

def truncated(val, max_length)
  case val
  when Numeric
    format("%.#{max_length}f", val)
  else
    val.to_s.truncate(max_length)
  end
end

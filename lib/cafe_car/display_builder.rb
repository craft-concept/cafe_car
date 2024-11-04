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

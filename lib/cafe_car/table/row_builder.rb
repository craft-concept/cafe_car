module CafeCar::Table
  class RowBuilder < Builder
    option :object, default: -> { raise }

    def href!
      @href = @options.delete(:href) { true }

      @href = @href.to_proc.(@object)     if @href.respond_to?(:to_proc)
      @href = nil                         if @href == false
    end

    def href                = @href
    def model               = @object.class
    def policy(o = @object) = @template.policy(o)

    def value(method) = @object.try(method)
    def show(...)  = present(@object).show(...)

    def cell(method, *flags, **options, &)
      super
      options[:href] = @object if options[:href] == true
      call_procs!(options, @object)
      ui.Cell(*flags, **options) { show(method, **options.slice(:blank), &) }
    end

    def timestamps(**options)
      tip = show(:created_at).string&.then { "Created: #{_1}" }
      cell(timestamp_attribute, :shrink, tip:, **options)
    end

    def controls(*args, **options)
      ui.Cell(:shrink, :shy, :controls, *args) { present(@object).controls(*args, **options) }
    end

    def to_html
      ui.Row { safe_join [ capture(self, &@block), @template.turbo_stream_from(@object) ] }
    end
  end
end

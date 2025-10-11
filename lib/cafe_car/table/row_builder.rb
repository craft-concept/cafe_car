module CafeCar::Table
  class RowBuilder < Builder
    def initialize(...)
      super
      @object = @options.delete(:object) { raise }
    end

    def href!
      @href = @options.delete(:href) { true }

      @href = @href.to_proc.(@object)     if @href.respond_to?(:to_proc)
      @href = nil                         if @href == false
    end

    def href                = @href
    def model               = @object.class
    def policy(o = @object) = @template.policy(o)

    def value(method) = @object.public_send(method)
    def show(...)  = present(@object).show(...)

    def cell(method, *flags, **options, &)
      super
      options[:href] = @template.href_for(@object) if options[:href] == true
      call_procs!(options, @object)
      ui.cell(show(method, &), *flags, **options)
    end

    def timestamps(**options)
      cell(:updated_at, :shrink, title: "Created: #{show(:created_at).string}", **options)
    end

    def controls(*args, **options)
      ui.cell(:shrink, :shy, :controls, *args, present(@object).controls(*args, **options))
    end

    def content = capture(self, &@block)

    def to_html
      ui.row(content, @template.turbo_stream_from(@object))
    end
  end
end

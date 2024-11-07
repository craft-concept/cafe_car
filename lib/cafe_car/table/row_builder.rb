module CafeCar::Table
  class RowBuilder < Builder
    def initialize(...)
      super
      @object = @options.delete(:object) { raise }
    end

    def model  = @object.class
    def policy = @template.policy(@object)

    def value(method) = present(@object.public_send(method))

    def cell(method, *flags, href: nil, **options, &block)
      href = @template.url_for(@object) if href == true
      href = href.to_proc.(@object) if href.respond_to?(:to_proc)

      content = block ? capture(value(method), &block) : value(method)

      ui.cell(content, *flags, href:, **options)
    end

    def timestamps(**options)
      cell(:updated_at, :shrink, title: "Created: #{value(:created_at).string}", **options)
    end

    def controls(*args, **options)
      ui.cell(:shrink, :shy, *args, present(@object).controls(*args, **options))
    end

    def to_html
      ui.row(capture(self, &@block))
    end
  end
end

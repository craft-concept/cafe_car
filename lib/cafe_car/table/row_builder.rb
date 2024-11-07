module CafeCar::Table
  class RowBuilder < Builder
    def initialize(...)
      super
      @object = @options.delete(:object) { raise }
    end

    def value(method) = present(@object).try(method) || @object.public_send(method)

    def cell(method, *flags, href: nil, **options, &block)
      href = @template.url_for(@object) if href == true
      href = href.to_proc.(@object) if href.respond_to?(:to_proc)

      content = block ? capture(value(method), &block) : present(value(method))

      ui.cell(content, *flags, href:, **options)
    end

    def timestamps(**options)
      cell(:updated_at, :shrink, title: value(:created_at), **options)
    end

    def controls(*args, **options)
      ui.cell(:shrink, :shy, *args, present(@object).controls(*args, **options))
    end

    def to_html
      ui.row(capture(self, &@block))
    end
  end
end

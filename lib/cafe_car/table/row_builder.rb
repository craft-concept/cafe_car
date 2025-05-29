module CafeCar::Table
  class RowBuilder < Builder
    def initialize(...)
      super
      @object = @options.delete(:object) { raise }
    end

    def model     = @object.class
    def policy    = @template.policy(@object)

    def value(method) = @object.public_send(method)
    def show(method)  = present(@object).show(method)

    def cell(method, *flags, href: nil, **options, &block)
      super
      href    = @template.href_for(@object) if href == true
      href    = href.to_proc.(@object) if href.respond_to?(:to_proc)
      value   = show(method)
      content = block ? capture(value, &block) : value

      ui.cell(content, *flags, href:, **options)
    end

    def timestamps(**options)
      cell(:updated_at, :shrink, title: "Created: #{show(:created_at).string}", **options)
    end

    def controls(*args, **options)
      ui.cell(:shrink, :shy, :controls, *args, present(@object).controls(*args, **options))
    end

    def to_html
      ui.row(capture(self, &@block))
    end
  end
end

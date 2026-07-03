module CafeCar::Table
  class HeadBuilder < ObjectsBuilder
    attr_reader :fields

    def initialize(...)
      @fields = []
      super
    end

    def cell(method, *flags, label: label(method), **, &)
      super
      @fields << model.info.field(method)
      ui.Cell(*flags) { label }
    end

    def label(method)
      l = LabelBuilder.new(@template, objects: @objects, method:)
      @objects.includes!(method) if l.association?
      l
    end

    def controls(*, **) = cell(:controls, :controls, *, label: nil, **)

    def select(*, **)
      return unless @template.bulk_actions?
      check_all = @template.tag.input(type: :checkbox, data: { bulk_select_all: true }, "aria-label": "Select all")
      cell(:select, :select, *, label: check_all, **)
    end

    def to_html = ui.Head(:sticky) { capture(self, &@block) }
  end
end

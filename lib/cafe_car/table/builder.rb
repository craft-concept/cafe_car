module CafeCar::Table
  class Builder
    include CafeCar[:ProcHelpers]

    attr_reader :ui
    delegate :capture, :link_to, :href_for, :params, :present, :request, :safe_join, to: :@template

    def initialize(template, **options, &block)
      @template         = template
      @options          = options
      @block            = block
      @ui               = @template.ui.table.context
      @shown_attributes = {}
    end

    def model_name = model.model_name

    def cell(method, ...) = shown!(method).then { nil }
    def shown!(method)    = @shown_attributes[method] = true
    def shown             = @shown_attributes

    def title_attribute      = policy.title_attribute
    def title(*, **, &) = cell(title_attribute, *, href: true, **, &)

    def timestamps(...) = cell(:updated_at, ...)

    def remaining_attributes = policy.listable_attributes - @shown_attributes.keys

    def remaining(except: [])
      capture do
        (remaining_attributes - [*except]).each do |attr|
          ui << cell(policy.info(attr).displayable.method)
        end
      end
    end

    def html_safe? = true
    def to_s       = @to_s ||= to_html.to_s
  end
end

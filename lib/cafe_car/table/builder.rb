module CafeCar::Table
  class Builder
    include CafeCar::ProcHelpers
    include CafeCar::OptionHelpers

    attr_reader :ui
    delegate :capture, :link_to, :href_for, :params, :present, :request, :safe_join, to: :@template

    def initialize(template, **options, &block)
      @template         = template
      @options          = options
      @block            = block
      @ui               = @template.ui.table.context
      @shown_attributes = {}
      assign_options!
    end

    def model_name = model.model_name

    def cell(method, ...) = shown!(method).then { nil }
    def shown!(method)    = @shown_attributes[method] = true
    def shown             = @shown_attributes

    def has?(method) = model.info.fields.has?(method)

    def title(method = policy.title_attribute, *, **, &)
      cell(method, *, href: true, **, &)
    end

    def logo(method = policy.logo_attribute, *, **, &)
      cell(method, *, label: nil, blank: "", **, &) if method
    end

    def timestamps(...) = cell(timestamp_attribute, ...)

    def timestamp_attribute = %w[updated_at created_at].find { has? _1 }

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

module CafeCar::Table
  class Builder
    attr_reader :ui
    delegate :capture, :link_to, :params, :present, :safe_join, to: :@template

    def initialize(template, **options, &block)
      @template = template
      @options  = options
      @block    = block
      @ui       = @template.ui.table.context
    end

    def html_safe? = true
    def to_s       = to_html.to_s
  end
end

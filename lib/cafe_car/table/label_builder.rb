module CafeCar::Table
  class LabelBuilder < ObjectsBuilder
    def initialize(...)
      super
      @method  = @options.delete(:method) { raise }
      @key     = @method.to_s
    end

    def sortable?    = @objects.columns_hash.key? @key
    def reflection   = @objects.klass.reflect_on_association(@method)
    def association? = reflection.present?
    def order_value  = @objects.order_values.first&.then { _1.expr.name }
    def existing     = params.fetch(:sort) { order_value }

    def sort
      @sort ||=
        case existing
        when @key then "-#{existing}"
        else @key
        end
    end

    def href
      @template.url_for(**request.params.merge(sort:)) if sortable?
    end

    def label_sort
      @template.tag.span(symbol) if sortable?
    end

    def symbol
      case existing
      when @key       then "↑" # ▴↑▲
      when "-#{@key}" then "↓" # ▾↓▼
      else "•"
      end
    end

    def label   = present(@objects).human(@method)
    def content = @template.safe_join([label, label_sort], "&nbsp;".html_safe)
    def to_html = @template.link_to_unless(!sortable?, content, href)
  end
end

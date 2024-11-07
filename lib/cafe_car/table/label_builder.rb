module CafeCar::Table
  class LabelBuilder < Builder
    def initialize(...)
      super
      @objects = @options.delete(:objects) { raise }
      @method  = @options.delete(:method) { raise }
      @key     = @method.to_s
    end

    def sortable? = @objects.columns_hash.key? @key

    def sort
      @sort ||=
        case params[:sort]
        when @key then "-#{params[:sort]}"
        else @key
        end
    end

    def href
      @template.url_for(**params.permit!.merge(sort:)) if sortable?
   end

    def label_sort
      @template.tag.small(symbol) if sortable?
    end

    def symbol
      case params[:sort]
      when @key       then "↑" # ▴↑▲
      when "-#{@key}" then "↓" # ▾↓▼
      else "•"
      end
    end

    def label   = present(@objects).human(@method)
    def content = @template.safe_join([label, label_sort], " ")
    def to_html = @template.link_to_unless(!sortable?, content, href)
  end
end

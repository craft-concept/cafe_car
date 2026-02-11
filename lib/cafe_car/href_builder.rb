module CafeCar
  class HrefBuilder
    attr_reader :parts, :namespace

    def initialize(*parts, namespace: [], template: nil, **params)
      @params    = params
      @parts     = parts
      @namespace = namespace
      @template  = template
      normalize!
    end

    def to_s
      case [*@parts]
      in [String]
        [*@parts, *@params.to_query.presence].join(??)
      else
        @template.url_for([*collapsed_namespace, *@parts, @params])
      end
    end

    def normalize!
      @parts.flatten!
      @params.with_defaults!(@parts.extract_options!)
      @namespace = @namespace.underscore.split(?/).map(&:to_sym) if @namespace.is_a? String
      @params.delete(:action) if @params[:action].in? %i[show destroy index]
      self
    end

    def collapsed_namespace
      0.upto(@namespace.size) do |i|
        if parts_start_with? @namespace.drop(i)
          return @namespace.slice(0, i)
        end
      end
    end

    def expanded_parts
      @expanded_parts ||= @parts.flat_map { expand_part _1 }
    end

    private

    def expand_part(part)
      normalize case part
                when Symbol, String, Hash, Array then part
                when ActiveModel::Naming then part.model_name.collection
                when Class then part.name.underscore
                else expand_part(part.class)
                end
    end

    def normalize(part)
      case part
      when String
        part.split(?/).map(&:to_sym)
      else part
      end
    end

    def parts_start_with?(prefix)
      prefix.zip(expanded_parts).all? { _1 == _2 }
    end
  end
end

# def href(*parts, **params)
#   params.merge! parts.extract_options!
#   params.delete(:action) if %i[show destroy index].include? params[:action]
#   url_for([*namespace, *parts, params])
# end

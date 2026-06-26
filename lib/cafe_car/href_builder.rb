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
      case [ *@parts ]
      in [ String ]
        [ *@parts, *@params.to_query.presence ].join(??)
      in []
        @template.url_for(@params)
      else
        namespace = collapsed_namespace
        parts     = @parts.map { singular_resource(_1) }
        begin
          @template.url_for([ *namespace, *parts, @params ])
        rescue NoMethodError
          raise if namespace.empty?
          namespace.pop
          retry
        end
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

    # Records route polymorphically via the plural `route_key`. For a singular
    # resource (`resource :session`) that helper doesn't exist, so fall back to
    # the singular route key. Leaves non-records (symbols, strings) untouched.
    def singular_resource(part)
      name = model_name_for(part) or return part
      return part if @template.respond_to?("#{name.route_key}_path")

      @template.respond_to?("#{name.singular_route_key}_path") ?
        name.singular_route_key.to_sym : part
    end

    def model_name_for(part)
      klass = part.is_a?(Module) ? part : part.class
      klass.model_name if klass.respond_to?(:model_name)
    end

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

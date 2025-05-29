module CafeCar
  class HrefBuilder
    attribute :parts, default: [] do |*parts|
      @parts << parts.flatten
    end

    def initialize(*parts, namespace: [], template:, **params)
      @params    = params
      @parts     = parts
      @namespace = namespace
      @template  = template
      normalize!
    end

    def to_s = @template.url_for([*namespace, *@parts, params])

    private

    def normalize!
      @parts.flatten!
      @params.with_defaults!(@parts.extract_options!)
      @namespace  = @namespace.underscore.split(?/).map(&:to_sym) if @namespace.is_a? String
      @params.delete(:action) if @params[:action].in? %i[show destroy index]
    end
  end
end

# def href(*parts, **params)
#   params.merge! parts.extract_options!
#   params.delete(:action) if %i[show destroy index].include? params[:action]
#   url_for([*namespace, *parts, params])
# end

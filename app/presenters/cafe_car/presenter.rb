module CafeCar
  class Presenter
    attr_reader :object

    delegate :l, :t, to: :@template

    def self.present(template, object, **options)
      find(object.class).new(template, object, **options)
    end

    def self.find(klass)
      candidates(klass).filter_map { CafeCar[_1] }.first
    end

    def self.candidates(klass)
      klass.ancestors.lazy.map { "#{_1.name}Presenter" }
    end

    def initialize(template, object, **options)
      @template = template
      @object   = object
      @options  = options
    end

    def present(...) = self.class.present(@template, ...)

    def to_s
      raise "to_s unimplemented on this Presenter"
    end
  end
end

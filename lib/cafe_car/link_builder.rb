module CafeCar
  class LinkBuilder
    attr_reader :object

    delegate :link_to, to: :@template

    def initialize(template, object)
      @template = template
      @object   = object
    end

    def model      = object.is_a?(Class) ? object.class : object
    def model_name = model.model_name
    def policy     = @template.policy(object)

    def index(text = "← All #{model_name.human(count: 2)}")
      return "" unless policy.index?
      link_to text, [model]
    end
  end
end

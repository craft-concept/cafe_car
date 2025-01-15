module CafeCar
  class NavBuilder
    delegate :ui, :ui_class, to: :@template

    def initialize(template, **options)
      @template = template
      @options  = options
    end

    def named_routes = Rails.application.routes.named_routes.to_h.values
    def index_routes = named_routes.select { _1.requirements[:action] == "index" }

    def routes
      @routes ||= index_routes.reject { _1.name =~ /rails/ }
                              .uniq { _1.requirements }
    end

    def link_to(*args, **opts, &block)
      block ||= -> { @template.tag.span(_1, class: ui_class([:navigation, :link], :current)) }
      @template.link_to_unless_current(*args, class: ui_class([:navigation, :link]), **opts, &block)
    end
  end
end

module CafeCar
  class NavBuilder
    delegate :ui, :ui_class, :link_to, to: :@template

    def initialize(template, **options)
      @template = template
      @options  = options
    end

    def named_routes
      Rails.application.routes.named_routes.to_h.values
    end

    def routes
      @routes ||= named_routes
                    .select { _1.requirements[:action] == "index" }
                    .reject { _1.name =~ /rails/ }
                    .uniq { _1.requirements }
    end

    def link(*args, **opts, &block)
      ui.nav.context.link do
        link_to(*args, class: ui_class(:nav), **opts, &block)
      end
    end
  end
end

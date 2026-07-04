module CafeCar
  class Navigation
    class Route
      delegate :tag, :ui, :ui_class, :capture, :concat, :t, to: :@template
      delegate :name, :requirements, to: :@route

      def initialize(route, template:)
        @route = route
        @template = template
      end

      def controller = requirements[:controller]
      def action = requirements[:action]
      def index? = action == "index"
      def rails? = name =~ /rails/
      def group  = controller.split(?/)[..-2]
      def text   = controller.split(?/).last
      def params = requirements.clone.tap do |p|
        p[:controller] = "/" + p[:controller]
      end

      def icon_name = t(text, scope: "navigation.icon", default: nil)&.to_sym
      def icon = @template.icon(icon_name, :before)

      def content
        capture do
          concat icon
          concat text.titleize
        end
      end

      def link(**opts)
        ui.Navigation().Link(href: @template.href_for([ params ]), **opts) { content }
      end
    end

    def initialize(template, **options)
      @template = template
      @options  = options
    end

    delegate :ui_class, to: :@template

    def router = Rails.application.routes.router
    def named_routes = Rails.application.routes.named_routes.to_h.values.map { Route.new(_1, template: @template) }

    # Path to the opt-in dashboard overview, or nil until a host writes the
    # dashboard template (`app/views/cafe_car/dashboard/show.html.haml`) — its
    # existence is the opt-in. The dashboard route lives in the engine (not the
    # host's routes), so it's resolved through the engine's own url helpers — that
    # works from any host controller regardless of where CafeCar is mounted.
    def dashboard_href
      return unless @template.lookup_context.exists?("show", %w[cafe_car/dashboard], false)
      CafeCar::Engine.routes.url_helpers.dashboard_path
    end
    def index_routes = named_routes.select(&:index?)
    def groups = routes.group_by(&:group)

    def routes
      @routes ||= index_routes.reject(&:rails?)
                              .uniq(&:requirements)
    end

    def recognize(obj, **)
      req = case obj
      when String
              path = ActionDispatch::Journey::Router::Utils.normalize_path(path)
              env  = Rack::MockRequest.env_for(path, method: :get, **)
              ActionDispatch::Request.new(env)
      when ActionDispatch::Request then obj
      else raise "cannot recognize this obj"
      end

      router.recognize(req) do |route, params|
        return Route.new(route, template: @template)
      end
    end

    def current = recognize(@template.request)

    def link_to(*args, **opts, &block)
      block ||= -> { @template.tag.span(_1, class: ui_class([ :navigation, :link ], :current)) }
      @template.link_to_unless_current(*args, class: ui_class([ :navigation, :link ]), **opts, &block)
    end
  end
end

module CafeCar
  class Navigation
    class Route
      delegate :tag, :ui_class, :capture, :concat, :t, to: :@template
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

      def icon_name = t(text, scope: "navigation.icon")
      def icon = @template.icon(icon_name, :before)

      def content
        capture do
          concat icon
          concat text.titleize
        end
      end

      def link(**)
        @template.link_to_unless_current(content, params, class: ui_class([:navigation, :link]), **) do
          tag.span(content, class: ui_class([:navigation, :link], :current))
        end
      end
    end

    delegate :ui, :ui_class, to: :@template

    def initialize(template, **options)
      @template = template
      @options  = options
    end

    def named_routes = Rails.application.routes.named_routes.to_h.values.map { Route.new(_1, template: @template) }
    def index_routes = named_routes.select(&:index?)
    def groups = routes.group_by(&:group)

    def routes
      @routes ||= index_routes.reject(&:rails?)
                              .uniq(&:requirements)
    end


    def link_to(*args, **opts, &block)
      block ||= -> { @template.tag.span(_1, class: ui_class([:navigation, :link], :current)) }
      @template.link_to_unless_current(*args, class: ui_class([:navigation, :link]), **opts, &block)
    end
  end
end

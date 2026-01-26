module CafeCar
  module Helpers
    # Returns a new `Context`. Used for instantiating components: `ui.Button(:primary, "Submit")`
    def ui(*args, **, &)
      # For now, this must be defined in a helper instead of in the controller. Passing `view_context` or `helpers`
      # from the controller somehow breaks `capture`. `capture` will return the captured content, but the content
      # _also_ gets appended to the original output buffer.
      # This can be tested in a view by comparing the behavior of `= capture do` with
      # `= controller.view_context.capture do`; the latter outputs the content twice.
      if args.any?
        present(*args, **, &)
      elsif block_given?
        capture(&)
      else
        @ui ||= CafeCar::Context.new(self)
      end
    end

    def ui_class(names, *args, **opts)
      names  = [*names].map(&:to_s).map(&:camelize)
      name   = names.join("_")
      parent = names.first
      args.flatten!
      args.compact_blank!
      opts.compact_blank!

      flags = args.extract! { _1.is_a? Symbol } | opts.extract! { _1.is_a? Symbol }.keys
      flags.map! { [*parent, _1].join("-") }

      [*name, *flags, *args, *opts.keys].join(" ")
    end

    def body_classes = [*controller_path.split(?/), action_name, *@body_class]

    def title(object)
      present(object).title.presence.tap do |title|
        content_for(:title, title)
      end
    end

    def capture(*, &)
      super do
        yield(*).then { _1.try(:html_safe?) ? _1.to_s : _1 }
      end
    end

    def present(*args, **options)
      @presenters                  ||= {}
      @presenters[[args, options]] ||= CafeCar[:Presenter].present(self, *args, **options)
    end
    alias_method :p, :present

    def current_href?(...) = current_page? href_for(...)

    def href_for(*parts, namespace: self.namespace, **params)
      HrefBuilder.new(*parts, namespace:, template: self, **params).to_s
    end

    def context(name = nil, &)
      @context ||= []

      if block_given?
        @context << name
        r = capture(&)
        @context.pop
        r
      else
        @context
      end
    end

    def context?(*names)
      context.reverse_each do |ctx|
        return true if names.empty?
        names.pop if ctx == names.last
      end
      names.empty?
    end

    def link(object)
      @links         ||= {}
      @links[object] ||= CafeCar[:LinkBuilder].new(self, object)
    end

    def icon(name = nil, *, **, &)
      case name
      when Symbol
        class_ = name&.then { "iconoir-#{_1.to_s.dasherize}" }
      when String, Array
        label = name
      end

      ui.Icon(*label, *, tag: :i, class: class_, **, &)
    end

    def breadcrumbs(*items)
      ui.Row safe_join(items, icon(:nav_arrow_right, :dim))
    end

    def filter_form_for(objects, **options, &block)
      raise ArgumentError, "First argument to filter_form_for cannot be nil" if objects.nil?

      form_for CafeCar[:FilterBuilder].new(objects, parsed_params),
               builder: CafeCar["Filter::FormBuilder"],
               method: :get,
               url: "",
               as: "",
               **options,
               &block
    end

    def table_for(objects, **options, &block)
      CafeCar[:TableBuilder].new(self, objects:, **options, &block)
    end

    def debug?   = params.key?(:debug)
    def console? = params.key?(:console)

    def partial?(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.any?(path, prefixes, true)
    end

    def get_partial(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.find(path, prefixes, true)
    end

    def template_glob(glob)
      lookup_context.view_paths
        .flat_map { _1.send(:template_glob, glob) }
        .map { ActionView::TemplatePath.parse(_1) }
    end

    def navigation
      @navigation ||= CafeCar::Navigation.new(self)
    end

    def namespace
      @namespace ||= controller_path.split("/").tap(&:pop).map(&:to_sym)
    end

    def method_missing(name, ...)
      return ui.send(name, ...) if name =~ /^[A-Z]/
      super
    end
  end
end

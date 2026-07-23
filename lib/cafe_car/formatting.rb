module CafeCar
  # The safe, standalone subset of CafeCar's view helpers — value formatting
  # through the presenters plus the component surface (`ui`, `href_for`,
  # `link`, …) — that every host view gets from `include CafeCar::Controller`
  # (and that a host without the include can expose with
  # `helper CafeCar::Formatting`). Everything here is purely additive: nothing
  # overrides or shadows a Rails or Ruby method. The admin-only overrides
  # (link_to, capture, the `p` alias, and the Capitalized `method_missing` →
  # `ui` routing) have heavy blast radius in a host app, so they stay in
  # CafeCar::Helpers, wired only by the `cafe_car` macro or an explicit
  # `helper CafeCar::Helpers`.
  module Formatting
    # Format `value` with CafeCar's presenters — `present(amount, as: :currency)`,
    # `present(date, as: :date)`, `present(record)`. Memoized per view render.
    # The same entry point CafeCar's own views use, offered on its own so a host
    # can format values without adopting the admin helper set. The scalar path
    # (`as: :currency/:date/...`) renders through Rails' own number/date helpers —
    # no admin CSS or partials.
    def present(*args, **options)
      @presenters                    ||= {}
      @presenters[[ args, options ]] ||= CafeCar[:Presenter].present(self, *args, **options)
    end

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
      names  = [ *names ].map(&:camelize)
      name   = names.join("_")
      args.flatten!
      args.compact_blank!
      opts.compact_blank!
      opts.merge!(*args.extract!(Hash))

      flags = args.extract!(Symbol)
      flags |= opts.extract_if! { _1.is_a? Symbol }.keys
      flags.map! { "#{name}-#{_1}" }

      [ *name, *flags, *args, *opts.keys ].join(" ")
    end

    def current_href?(*, check_parameters: false, **) = current_page?(href_for(*, **), check_parameters:)
    def ancestor_href?(...) = URI(href_for(...)) < URI(url_for(request.url))

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

    def partial?(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.any?(path, prefixes, true)
    end

    def get_partial(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.find(path, prefixes, true)
    end

    def namespace
      @namespace ||= controller_path.split("/").tap(&:pop).map(&:to_sym)
    end
  end
end

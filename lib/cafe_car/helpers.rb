module CafeCar
  module Helpers
    # Returns a new `Context`. Used for instantiating components: `ui.button(:primary, "Submit")`
    def ui(*args, **options)
      # For now, this must be defined in a helper instead of in the controller. Passing `view_context` or `helpers`
      # from the controller somehow breaks `capture`. `capture` will return the captured content, but the content
      # _also_ gets appended to the original output buffer.
      # This can be tested in a view by comparing the behavior of `= capture do` with
      # `= controller.view_context.capture do`; the latter outputs the content twice.
      if args.any?
        present(*args, **options)
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

    def title(object)
      @title = present(object).title.presence
    end

    def present(*args, **options)
      @presenters                  ||= {}
      @presenters[[args, options]] ||= CafeCar[:Presenter].present(self, *args, **options)
    end

    def current_href?(...) = current_page? href_for(...)

    def href_for(*parts, **params)
      params.merge! parts.extract_options!
      params.delete(:action) if %i[show destroy index].include? params[:action]
      url_for([*parts, params])
    end

    def link(object)
      @links         ||= {}
      @links[object] ||= CafeCar[:LinkBuilder].new(self, object)
    end

    def table_for(objects, **options, &block)
      CafeCar[:TableBuilder].new(self, objects:, **options, &block)
    end

    def partial?(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.any?(path, prefixes, true)
    end

    def get_partial(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.find(path, prefixes, true)
    end
  end
end

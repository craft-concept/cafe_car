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

    def body_classes = [ *controller_path.split(?/), action_name, *@body_class ]

    # Stylesheet <link> for the active bundled theme (`CafeCar.theme`), injected
    # into every CafeCar page's <head>. Each theme is self-contained — its light
    # tokens plus a `prefers-color-scheme: dark` block — so dark mode needs no
    # separate tag. Emitted after `application.css` so its `:root` tokens win.
    def theme_stylesheet_tag
      stylesheet_link_tag "cafe_car/themes/#{CafeCar.theme}", "data-turbo-track": "reload"
    end

    def title(object)
      present(object).title.presence.tap do |title|
        content_for(:title, title)
      end
    end

    def cat(*args)
      args.flatten.each do |arg|
        arg = capture(&arg) if arg.respond_to?(:to_proc)
        arg = arg.to_s
        concat(arg) if arg.present?
      end
    end

    def cap(*)
      capture { cat(*) }
    end

    def capture(*, &)
      super do
        yield(*).then { _1.try(:html_safe?) ? _1.to_s : _1 }
      end
    end

    def present(*args, **options)
      @presenters                  ||= {}
      @presenters[[ args, options ]] ||= CafeCar[:Presenter].present(self, *args, **options)
    end
    alias_method :p, :present

    def current_href?(*, check_parameters: false, **) = current_page?(href_for(*, **), check_parameters:)
    def ancestor_href?(...) = URI(href_for(...)) < URI(url_for(request.url))

    def href_for(*parts, namespace: self.namespace, **params)
      HrefBuilder.new(*parts, namespace:, template: self, **params).to_s
    end

    def view_url(view)
      view = view.to_s
      params = request.params.merge(view:)
      params.delete(:view) if params[:view] == default_view
      url_for(params)
    end

    # Current index URL as `.csv`, carrying the on-screen filter + sort params so
    # the export matches the view. Pagination is dropped (CSV exports the full set).
    def csv_url = url_for(request.params.except("page", "per").merge(format: :csv))

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

    def link_to(...)
      raise ArgumentError, "Links cannot be nested" if context?(:a)
      context(:a) { super }
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
      ui.Row safe_join(items.compact_blank, icon(:nav_arrow_right, :dim))
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

    def chart_for(objects, **options)
      CafeCar[:ChartBuilder].new(self, objects:,
        column: params[:chart_x], bucket: params[:chart_by], **options)
    end

    # The bulk actions offered on this model's index table — the model policy's
    # `permitted_bulk_actions` list is the source of truth. This only decides which
    # buttons show; each selected row is still authorized one-by-one in the
    # controller, so a shown action never bulk-bypasses a per-record denial.
    def bulk_actions(klass = model)
      policy(klass.new).permitted_bulk_actions
    end

    def bulk_actions? = bulk_actions.any?

    # A single bulk-action submit button, wired to the table's BulkForm from the
    # toolbar (`form: "BulkForm"`). The label comes from the locale (`en.destroy`),
    # never a hardcoded string, and the button style from the locale too — a shipped
    # default maps `destroy` to `:danger` (see `bulk_actions.styles`). The default
    # `_bulk_actions` partial loops `bulk_actions` calling this; a host overriding
    # the partial can call it directly for a bespoke set.
    def bulk_action(name, style = bulk_action_style(name))
      label   = t(name, default: name.to_s.humanize)
      confirm = t(:bulk_confirm, scope: :helpers, action: label)
      Button(*style, tag: :button, type: :submit, form: "BulkForm",
        name: :bulk_action, value: name, data: { turbo_confirm: confirm }) { label }
    end

    # The button style (a Button flag like `:danger`) for a bulk action, from the
    # locale under `bulk_actions.styles`, or nil for the default style.
    def bulk_action_style(name)
      t("bulk_actions.styles.#{name}", default: nil)&.to_sym
    end

    # A dashboard metric tile: a label over the value captured from the block. The
    # block is host-authored (a real view), evaluated at render.
    def metric(label, &block)
      render "cafe_car/dashboard/metric", label:, value: capture(&block)
    end

    # A dashboard chart tile: a title over the dependency-free inline-SVG bar chart,
    # built from `model`'s records bucketed over the `x` date column at `by`
    # granularity. `x` runs through ChartBuilder's date-column allowlist unchanged,
    # so a column name can never reach SQL raw.
    def chart(title, model:, x:, by: nil)
      render "cafe_car/dashboard/chart", title:, objects: model.all, x:, by:
    end

    # The policy-driven metric tiles for `model`: one count tile per name in the
    # model policy's `permitted_metrics` (`:all` = the whole relation). This is the
    # default dashboard behavior — a host template overrides by calling `metric`
    # directly instead.
    def metrics(model)
      policy = policy(model.new)
      safe_join(policy.permitted_metrics.map { metric_for(model, _1) })
    end

    def metric_for(model, name)
      scope = name.to_sym == :all ? model.all : model.public_send(name)
      metric(metric_label(model, name)) { scope.count }
    end

    # A metric tile's label, from the locale: the pluralized model name for the
    # whole-relation `:all` metric, else `metrics.<name>` (defaulting to the
    # humanized scope name).
    def metric_label(model, name)
      return model.model_name.human(count: 2) if name.to_sym == :all
      t("metrics.#{name}", default: name.to_s.humanize)
    end

    # Wraps the index table in the form that submits the selected row ids and the
    # chosen bulk action. With no bulk actions available, the table renders as-is.
    # The action bar itself lives up in the index toolbar (next to the search box);
    # its buttons reach back into this form by id via their `form="BulkForm"`.
    def bulk_form(&block)
      content = capture(&block)
      return content unless bulk_actions?

      form_tag(url_for(action: :batch), method: :post, class: "BulkForm", id: "BulkForm") do
        content
      end
    end

    def debug?   = params.key?(:debug)
    def console? = params.key?(:console)

    def comment(text)
      "<!-- #{text} -->".html_safe
    end

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

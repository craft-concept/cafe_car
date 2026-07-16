module CafeCar
  module Helpers
    # The safe formatting subset (`present`). Everything else in this module —
    # the link_to/capture/method_missing/`p` overrides especially — is admin-only
    # and unsafe app-wide; a host wanting formatting uses CafeCar::Formatting.
    include Formatting

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

    def capture(*args, &)
      # form_for/form_with/fields_for capture their block with the builder as the
      # first arg — track that we're inside a CafeCar form so field_error_proc can
      # drop Rails' `field_with_errors` wrapper here without touching host forms.
      form = args.first.is_a?(CafeCar[:FormBuilder])
      @_cafe_car_form_depth = @_cafe_car_form_depth.to_i + 1 if form
      super do
        yield(*args).then { _1.try(:html_safe?) ? _1.to_s : _1 }
      end
    ensure
      @_cafe_car_form_depth -= 1 if form
    end

    # `p` aliases `present` for terse view code — a deliberate shadow of Kernel#p
    # that is admin-only (it stays out of CafeCar::Formatting).
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

    # The active-filter chips above the index: one per leaf in the policy-gated
    # filter set (permitted_filter_params), each carrying its human label, display
    # value, and the URL that removes just that one filter — the current params
    # minus its single key, so every OTHER filter plus q/sort/view survive.
    # Reflecting the gated set (not raw request params) means a stray or
    # non-permitted param never grows a chip.
    def active_filters(klass = model)
      flatten_filters(permitted_filter_params).map do |key, value|
        { key:, label: filter_label(klass, key), value: filter_value(klass, key, value),
          remove_url: url_for(request.params.except(key, "page")) }
      end
    end

    # "Clear all" target: the current params minus every active filter key (and
    # the now-stale page), keeping the control params — q, sort, view, per.
    def clear_filters_url
      url_for(request.params.except(*flatten_filters(permitted_filter_params).keys, "page"))
    end

    # Flattens the nested gated filter params back to the flat dot-keyed params
    # request.params carries: every nested hash — an operator group (`{min:}`) or
    # an association hop (`{client: {status:}}`) — recurses, joining segments with
    # ".", so a leaf's key is exactly the one url_for drops to remove it. Non-hash
    # leaves (a scalar, an id set, a parsed Range) end the walk.
    def flatten_filters(params, prefix = "")
      params.each_with_object({}) do |(key, value), flat|
        path = "#{prefix}#{key}"
        value.is_a?(Hash) ? flat.merge!(flatten_filters(value, "#{path}.")) : flat[path] = value
      end
    end

    # The human label for a filter key, from the same Filter::FieldInfo the panel
    # controls read (policy/locale-driven, with a humanized-attribute fallback) —
    # never the raw column/operator key.
    def filter_label(klass, key)
      CafeCar["Filter::FieldInfo"].new(model: klass, method: filter_method(key)).label
    end

    # A filter key reduced to the attribute path its label reads: the trailing
    # operator char (`name~`) and a trailing word-operator segment (`price.min`)
    # drop off; a nested association path (`client.status`) keeps its dots.
    def filter_method(key)
      segments = key.to_s.sub(/\W+$/, "").split(".")
      segments.pop if segments.size > 1 && CafeCar::QueryBuilder::OPS.key?(segments.last)
      segments.join(".")
    end

    # A filter value as chip text. An association filter — a belongs_to foreign-key
    # set (`owner_id[]`) or a has_many/has_one membership set (`line_items.id[]`) —
    # shows each referenced record's TITLE (the same title the filter's typeahead
    # lists), so a chip reads "Owner: Jane Doe" not "Owner: 42". The whole set is
    # resolved in ONE query, and an id that no longer resolves falls back to its raw
    # value. Every other filter (enum/string/range/boolean) prints its value(s) as-is.
    def filter_value(klass, key, value)
      ids   = Array.wrap(value)
      assoc = filter_association(klass, key)
      return ids.join(", ") unless assoc
      return ids.join(", ") unless policy(assoc).index?

      titles = policy_scope(assoc).where(id: ids).index_by { _1.id.to_s }
      ids.map { |id| titles[id.to_s]&.then { present(_1).title } || id }.join(", ")
    end

    # The model whose records an association filter's values are ids of, or nil for
    # a non-association filter. A foreign-key set resolves through the terminal
    # belongs_to; a membership set (`<assoc>.id[]`) through the association named
    # just before the `.id`. Reflects through the same Filter::FieldInfo the panel
    # controls read, so titling never diverges from what the control's select shows.
    def filter_association(klass, key)
      method          = filter_method(key)
      parent, _, leaf = method.rpartition(".")
      method          = parent if leaf == "id" && parent.present?
      field           = CafeCar["Filter::FieldInfo"].new(model: klass, method:)
      field.reflection&.klass if field.type.in?(%i[belongs_to has_many has_one])
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
        column: params[:chart_x], bucket: params[:chart_by], metric: params[:chart_y], **options)
    end

    # The bulk actions offered on this model's index table — the model policy's
    # `permitted_bulk_actions` list is the source of truth. This only decides which
    # buttons show; each selected row is still authorized one-by-one in the
    # controller, so a shown action never bulk-bypasses a per-record denial.
    def bulk_actions(klass = model)
      policy(klass.new).attributes.actions.bulk
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

    # The custom collection actions offered in this model's index toolbar — the
    # model policy's `permitted_collection_actions` list is the source of truth,
    # like #bulk_actions. This only decides which buttons show; the controller
    # re-authorizes the POST (see Controller#collection_action).
    def collection_actions(klass = model)
      policy(klass.new).attributes.actions.collection
    end

    # A collection-action button for the index toolbar: POSTs the named action
    # to the generic collection route (Controller#collection_action), carrying the
    # active filters + search so the action runs over exactly the viewed set. The
    # label appends that set's count (localized `helpers.collection_action` — e.g.
    # "Publish all 21"); style and confirm come from the locale like #bulk_action.
    def collection_action(name, style = action_style(name))
      count   = filtered_scope.count
      action  = t(name, default: name.to_s.humanize)
      label   = t(:collection_action, scope: :helpers, action:, count:)
      confirm = t(:collection_confirm, scope: :helpers, action:, count:,
                  models: model.model_name.human(count:).downcase)
      filters = search_term ? filter_params.merge(q: search_term) : filter_params
      url     = url_for(filters.merge(action: :collection_action, collection_action: name))
      button_to label, url, class: ui.Button(*style).class_name, data: { turbo_confirm: confirm }
    end

    # The button style for a custom (member or collection) action, from the
    # locale under `actions.styles` — the same convention as #bulk_action_style.
    def action_style(name)
      t("actions.styles.#{name}", default: nil)&.to_sym
    end

    # A dashboard metric tile: a label over the value captured from the block. The
    # block is host-authored (a real view), evaluated at render.
    def metric(label, &block)
      render "cafe_car/dashboard/metric", label:, value: capture(&block)
    end

    # A dashboard chart tile: a title over the dependency-free inline-SVG bar chart,
    # built from `model`'s records bucketed over the `x` date column at `by`
    # granularity. `x` runs through ChartBuilder's date-column allowlist unchanged,
    # so a column name can never reach SQL raw. The model's policy scope is the
    # chart's row boundary.
    def chart(title, model:, x:, by: nil)
      render "cafe_car/dashboard/chart", title:, objects: policy_scope(model), x:, by:
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
      scope = policy_scope(model)
      scope = scope.public_send(name) unless name.to_sym == :all
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

    def debug?   = Rails.env.development? && request.local? && params.key?(:debug)
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

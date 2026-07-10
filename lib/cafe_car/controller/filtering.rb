module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  # URL params CafeCar consumes for control flow (sorting, pagination, view
  # switching, keyword search) plus Rails' routing/form internals. Everything
  # else on an index request is treated as a filter, so a bare `?price.min=10`
  # or `?name=Widget` reaches the query DSL without a namespacing prefix.
  CONTROL_PARAMS = %w[
    controller action format id
    sort page per view tab q chart_x chart_y chart_by
    _method authenticity_token commit utf8 button _
  ].freeze

  included do
    helper_method :parsed_params, :filter_params, :permitted_filter_params,
                  :filtered?, :search_term, :filtered_scope
  end

  private

  def filtered(scope)
    scope.query([ permitted_filter_params, search_term ].compact_blank)
  end

  # The policy-scoped collection narrowed by the active filters + keyword search
  # — the set the index is showing, before sorting/pagination. The single source
  # of truth for "the viewed scope": #scope sorts + paginates it for display, a
  # collection action runs its bang over exactly this set (Controller#collection_action),
  # and the toolbar button counts it (Helpers#collection_action).
  def filtered_scope(klass = model)
    filtered(policy_scope(klass))
  end

  def filtered?
    permitted_filter_params.present? || search_term.present?
  end

  # The filter params the policy permits — the enforcement half of the
  # policy-is-source-of-truth pattern (Policy#permitted_filters /
  # #permitted_scopes). Keys the policy doesn't list are silently dropped: a
  # stray or hostile param just doesn't filter (no 400, and it never reaches
  # the query DSL where an unknown key would raise).
  def permitted_filter_params
    @permitted_filter_params ||= prune_filters(policy(model.new), model, parsed_params[""] || {})
  end

  # Recursively keep only filter params whose FULL dot-path the policy permits.
  # An association keyed to a nested hash (`{client: {status: ...}}`, not an
  # operator group like `{min:, max:}`) is descended into the far model, extending
  # the path; every other entry is a leaf validated at its full path. A crafted
  # `?client.owner.secret=` — an undeclared nested path — is pruned here, before
  # the query DSL builds any join. The security guarantee is identical to the
  # top-level gate, just path-aware: the FULL path must clear #permitted_filter?.
  def prune_filters(policy, klass, params, prefix = "")
    params.each_with_object({}) do |(key, value), kept|
      base = key.to_s.sub(/\W+$/, "")
      ref  = klass.reflect_on_association(base)
      if ref && value.is_a?(Hash) && !operator_params?(value)
        nested = prune_filters(policy, ref.klass, value, "#{prefix}#{base}.")
        kept[key] = nested if nested.present?
      elsif permits_filter?(policy, klass, "#{prefix}#{base}", base)
        kept[key] = value
      end
    end
  end

  # Classify a filter key the way QueryBuilder#param! does — on the base name,
  # operator suffix stripped (`price>` → price, `title~` → title): a known
  # attribute or association checks #permitted_filters at its full (possibly
  # nested) path, anything else is a would-be scope and checks #permitted_scopes
  # (scopes are top-level only, so `base` alone is right there).
  def permits_filter?(policy, klass, path, base)
    if klass.reflect_on_association(base) || klass.columns_hash.key?(base)
      policy.permitted_filter?(path)
    else
      policy.permitted_scope?(base)
    end
  end

  # A filter value whose keys are ALL comparison operators (`{min:, max:}`) is a
  # terminal operator group, not a nested-association hash — the same test
  # QueryBuilder#operators? makes before desugaring it to a range.
  def operator_params?(hash)
    hash.any? && hash.keys.all? { CafeCar::QueryBuilder::OPS.key?(_1.to_s) }
  end

  # The `?sort=` keys the policy permits — the sort half of the same gate that
  # guards filtering. Ordering exposes a column's values as surely as filtering
  # does, so a key is honored only when its base attribute clears
  # #permitted_filter?; a non-permitted or hidden column (e.g. password_digest,
  # or an attribute a policy leaves off #permitted_filters) is dropped before it
  # reaches Model.sorted. A leading "-" (descending) and an `assoc.column`
  # association-sort suffix are stripped to find the base name.
  def permitted_sort
    policy = policy(model.new)
    sort_keys.select { |key| policy.permitted_filter?(sort_base(key)) }
  end

  def sort_keys = params[:sort].to_s.split(",").filter_map { _1.strip.presence }

  def sort_base(key) = key.delete_prefix("-").split(".", 2).first

  # Keyword term from the index search box. Read raw (not through ParamParser) so a
  # term keeps its literal text, then funneled into the query DSL as a bare String
  # that routes to `QueryBuilder#search!` alongside the dot-filters. Only a String
  # counts — a crafted `?q[x]=y` (Hash) or `?q[]=a` (Array) is ignored, not searched
  # (otherwise the non-String would reach the query DSL and raise a 500).
  def search_term = (params[:q] if params[:q].is_a?(String)).presence

  # Raw (unparsed) filter params — every request param that isn't a control
  # param — for round-tripping the active filter into hidden form fields so a
  # search or sort resubmission keeps it.
  def filter_params
    request.params.except(*CONTROL_PARAMS)
  end

  # Filters always ride the URL, never a request body: on an index GET the whole
  # param set is filters; on a collection-action POST they ride the query string
  # (see Helpers#collection_action). A model-mutation POST (create/update) has no
  # query string, so its body stays raw — it never reads parsed_params anyway.
  def parsed_params
    @parsed_params ||=
      if request.get? || request.head?
        parse(request.params)
      elsif request.query_parameters.present?
        parse(request.query_parameters)
      else
        request.params
      end
  end

  # Nest dot-keyed params (`price.min` → `{price: {min:}}`) via ParamParser, then
  # stash the filter subset (control params removed) under "" for
  # #permitted_filter_params.
  def parse(params)
    parsed = CafeCar::ParamParser.new(params).parsed
    parsed.merge("" => parsed.except("", *CONTROL_PARAMS))
  end
end

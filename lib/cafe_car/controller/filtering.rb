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
    helper_method :parsed_params, :filter_params, :filtered?, :search_term
  end

  private

  def filtered(scope)
    scope.query([ permitted_filter_params, search_term ].compact_blank)
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
    @permitted_filter_params ||= begin
      policy = policy(model.new)
      (parsed_params[""] || {}).select { |key, _| permits_filter?(policy, key) }
    end
  end

  # Classify a filter key the way QueryBuilder#param! does — on the base name,
  # operator suffix stripped (`price>` → price, `title~` → title): a known
  # attribute or association checks #permitted_filters, anything else is a
  # would-be scope and checks #permitted_scopes.
  def permits_filter?(policy, key)
    base = key.to_s.sub(/\W+$/, "")
    if model.reflect_on_association(base) || model.columns_hash.key?(base)
      policy.permitted_filter?(base)
    else
      policy.permitted_scope?(base)
    end
  end

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

  def parsed_params
    @parsed_params ||=
      if request.get? || request.head?
        parsed = CafeCar::ParamParser.new(request.params).parsed
        parsed.merge("" => parsed.except("", *CONTROL_PARAMS))
      else
        request.params
      end
  end
end

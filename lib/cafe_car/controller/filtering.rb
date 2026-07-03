module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  # URL params CafeCar consumes for control flow (sorting, pagination, view
  # switching, keyword search) plus Rails' routing/form internals. Everything
  # else on an index request is treated as a filter, so a bare `?price.min=10`
  # or `?name=Widget` reaches the query DSL without a namespacing prefix.
  CONTROL_PARAMS = %w[
    controller action format id
    sort page per view tab q chart_x chart_by
    _method authenticity_token commit utf8 button _
  ].freeze

  included do
    helper_method :parsed_params, :filter_params, :filtered?, :search_term
  end

  private

  def filtered(scope)
    scope.query([ parsed_params[""], search_term ].compact_blank)
  end

  def filtered?
    parsed_params[""].present? || search_term.present?
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

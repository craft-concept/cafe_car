module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  included do
    helper_method :parsed_params, :dot_params, :filtered?, :search_term
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

  def dot_params
    request.params.slice(*request.params.keys.grep(/^\./))
  end

  def parsed_params
    @parsed_params ||=
      if request.get? || request.head?
        CafeCar::ParamParser.new(request.params).parsed
      else
        request.params
      end
  end
end

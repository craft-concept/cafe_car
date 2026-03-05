module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  included do
    helper_method :parsed_params, :dot_params, :filtered?
  end

  private

  def filtered(scope)
    scope.query(parsed_params[""])
  end

  def filtered?
    parsed_params[""].present?
  end

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

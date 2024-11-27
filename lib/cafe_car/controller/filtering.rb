module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  included do
    helper_method :parsed_params
  end

  private

  def filtered(scope)
    scope.query(parsed_params[""])
  end

  def parsed_params
    @parsed_params ||= CafeCar::ParamParser.new(request.params).parsed
  end
end

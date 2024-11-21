module CafeCar::Controller::Filtering
  extend ActiveSupport::Concern

  included do
    helper_method :dot_params
  end

  private

  def filtered(scope)
    scope.query(dot_params[""])
  end

  def parsed_params
    @parsed_params ||= params.reject {|k, *| k.include?('.') }.
      merge(dot_params)
  end

  def dot_params
    @dot_params ||= CafeCar::ParamParser.new(request.params).parsed
  end
end

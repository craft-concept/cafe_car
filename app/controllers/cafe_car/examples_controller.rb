module CafeCar
  class ExamplesController < ApplicationController
    helper CafeCar::Helpers

    before_action :skip_policy_scope, only: :index
    before_action :skip_authorization, only: :index

    def index
      @examples = view_context.template_glob("cafe_car/examples/ui/*")
        .map { _1.name.sub(/\..+$/, "") }
        .to_h { [_1, "cafe_car/examples/ui/#{_1}"] }
    end

    private

    def model_name = @model_name ||= ActiveModel::Name.new(:components)
  end
end

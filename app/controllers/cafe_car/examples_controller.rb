module CafeCar
  class ExamplesController < ApplicationController
    helper CafeCar::Helpers

    before_action :skip_policy_scope, only: :index
    before_action :skip_authorization, only: :index
    def index = nil

    private

    def model_name = @model_name ||= ActiveModel::Name.new(:component_examples)
  end
end

module CafeCar
  # The opt-in dashboard overview: renders the host's declared widgets (metric
  # tiles + charts) in a responsive grid. It has no model of its own, so it skips
  # the CRUD policy/authorization pipeline like the components gallery does. The
  # route is only mounted when a dashboard is declared (see config/routes.rb); the
  # runtime guard here 404s if the config is cleared after boot.
  class DashboardsController < const(:ApplicationController)
    include Controller
    helper CafeCar::Helpers

    before_action :skip_policy_scope
    before_action :skip_authorization

    def show
      head :not_found unless CafeCar.dashboard?
    end

    private

    def model_name = @model_name ||= ActiveModel::Name.new(:dashboard)
  end
end

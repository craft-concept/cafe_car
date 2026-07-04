module CafeCar
  # The opt-in dashboard overview. A host defines the dashboard by writing one
  # template — `app/views/cafe_car/dashboard/show.html.haml` — that composes the
  # `metric`/`chart` helpers (and the policy-driven `metrics` helper). Its existence
  # IS the opt-in: the route always mounts, but with no host template this 404s, so
  # a CRUD-only host never inherits a blank page. It has no model of its own, so it
  # skips the CRUD policy/authorization pipeline like the components gallery does.
  class DashboardsController < const(:ApplicationController)
    include Controller
    helper CafeCar::Helpers

    before_action :skip_policy_scope
    before_action :skip_authorization

    def show
      return head(:not_found) unless dashboard_template?
      render "cafe_car/dashboard/show"
    end

    private

    # Whether the host has written the dashboard template — the opt-in signal. The
    # engine ships no `cafe_car/dashboard/show`, so this is true only when the host
    # placed one at `app/views/cafe_car/dashboard/show`.
    def dashboard_template? = template_exists?("show", %w[cafe_car/dashboard], false)

    def model_name = @model_name ||= ActiveModel::Name.new(:dashboard)
  end
end

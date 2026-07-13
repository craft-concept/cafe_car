module CafeCar
  # The opt-in dashboard overview. A host defines the dashboard by writing one
  # template — `app/views/cafe_car/dashboard/show.html.haml` — that composes the
  # `metric`/`chart` helpers (and the policy-driven `metrics` helper). Its existence
  # IS the opt-in: the route always mounts, but with no host template this 404s, so
  # a CRUD-only host never inherits a blank page. An opted-in dashboard authorizes
  # the conventional `DashboardPolicy#show?`; its model helpers apply each model's
  # policy scope independently.
  class DashboardsController < const(:ApplicationController)
    include Controller
    helper CafeCar::Helpers

    rescue_from ::Pundit::NotAuthorizedError, ::Pundit::NotDefinedError, with: :render_unauthorized

    before_action :skip_policy_scope
    after_action :verify_authorized

    def show
      unless dashboard_template?
        skip_authorization
        return head(:not_found)
      end

      authorize :dashboard, :show?
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

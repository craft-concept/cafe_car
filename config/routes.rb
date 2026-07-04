CafeCar::Engine.routes.draw do
  # The `components` gallery is an unauthenticated UI demo, mounted for development
  # only so a host app never inherits a public, policy-skipping route in production.
  if Rails.env.development?
    scope module: :cafe_car, as: :cafe_car do
      get "components", to: "examples#index"
    end
  end

  # Opt-in login/logout. Singular resource so the form posts to /session and
  # request_authentication can redirect to new_session_path.
  resource :session, only: %i[new create destroy], controller: "cafe_car/sessions"

  # The dashboard overview is opt-in via a host template, not config: the route
  # always mounts, but the controller 404s unless the host has written
  # `app/views/cafe_car/dashboard/show.html.haml`. So a CRUD-only host that never
  # writes the template sees no dashboard (404 on direct hit, no nav link), while
  # opt-in stays a matter of "drop a view" — the same convention as every other
  # CafeCar surface. (Routes are drawn at boot, before any view context, so the
  # template check can't gate the mount itself.)
  get "dashboard", to: "cafe_car/dashboards#show", as: :dashboard
end

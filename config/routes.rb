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

  # The dashboard overview is opt-in: its route exists only when a host has
  # declared widgets via `CafeCar.dashboard { ... }`. With nothing declared the
  # engine mounts no route, so a CRUD-only host never inherits a blank page.
  if CafeCar.dashboard?
    get "dashboard", to: "cafe_car/dashboards#show", as: :dashboard
  end
end

CafeCar::Engine.routes.draw do
  scope module: :cafe_car, as: :cafe_car do
    get "components", to: "examples#index"
  end

  # Opt-in login/logout. Singular resource so the form posts to /session and
  # request_authentication can redirect to new_session_path.
  resource :session, only: %i[new create destroy], controller: "cafe_car/sessions"
end

CafeCar::Engine.routes.draw do
  scope module: :cafe_car, as: :cafe_car do
    resources :examples, only: [:index]
  end
end

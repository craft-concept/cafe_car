CafeCar::Engine.routes.draw do
  scope module: :cafe_car, as: :cafe_car do
    get 'components', to: "examples#index"
  end
end

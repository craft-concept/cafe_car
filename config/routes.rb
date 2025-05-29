CafeCar::Engine.routes.draw do
  scope module: :cafe_car, as: :cafe_car do
    get 'style_guide', to: "examples#index"
  end
end

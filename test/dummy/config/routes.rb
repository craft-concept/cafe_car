Rails.application.routes.draw do
  mount CafeCar::Engine => "/admin"
  get "up" => "rails/health#show", as: :rails_health_check

  resources :articles
  resources :users

  get "*path", to: "pages#show", as: :page
  root "pages#show"
end

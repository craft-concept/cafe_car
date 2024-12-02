Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :articles

  namespace :admin do
    mount CafeCar::Engine => "/"
    resources :articles
    resources :users
  end

  get "*path", to: "pages#show", as: :page
  root "pages#show"
end

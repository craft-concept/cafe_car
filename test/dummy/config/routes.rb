Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :articles

  namespace :admin do
    resources :articles
    resources :users

    mount CafeCar::Engine => "/"
  end

  get "*path", to: "pages#show", as: :page
  root "pages#show"
end

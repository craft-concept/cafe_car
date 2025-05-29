Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :articles

  namespace :admin do
    resources :invoices
    resources :clients
    resources :articles
    resources :users
    resources :notes
    resources :line_items

    mount CafeCar::Engine => "/"
  end

  get "*path", to: "pages#show", as: :page
  root "pages#show"
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :articles
  resources :users
  root "articles#index"
end

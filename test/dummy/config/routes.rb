Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :posts
  root "posts#index"
end

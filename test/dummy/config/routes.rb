Rails.application.routes.draw do
  # mount ActiveStorage::Engine => '/'

  get "up" => "rails/health#show", as: :rails_health_check

  resources :articles
  resources :users, path: :authors

  namespace :admin do
    resources :articles
    resources :clients
    resources :invoices
    resources :notes
    resources :users

    resources :attachments

    namespace :active_storage do
      resources :attachments
    end

    mount CafeCar::Engine => "/"
  end

  Rails.application.initializer "page_route" do |app|
    app.routes.append do
      get "*path", to: "pages#show", as: :page
    end
  end

  root "pages#show"
end

Rails.application.routes.draw do
  resource :session, controller: "cafe_car/sessions"# , as: :session
  # Plain `resources`, no CafeCar — these must never gain CafeCar endpoints
  # (see routing_test.rb).
  resources :passwords, param: :token, only: %i[ new create edit update ]
  resources :denials, only: :index
  # mount ActiveStorage::Engine => '/'

  get "up" => "rails/health#show", as: :rails_health_check

  cafe_car :articles
  cafe_car :users, path: :authors

  namespace :admin do
    cafe_car :articles
    cafe_car :clients
    cafe_car :invoices
    cafe_car :notes
    cafe_car :users
    cafe_car :sessions

    cafe_car :attachments

    # Exercise `cafe_car only:`/`except:` narrowing (see narrowing_test.rb):
    # the routes are drawn in full so the CONTROLLERS' own gate is what the
    # tests hit.
    cafe_car :readonly_articles
    cafe_car :permanent_articles

    namespace :paper_trail do
      cafe_car :versions
    end

    namespace :active_storage do
      cafe_car :attachments
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

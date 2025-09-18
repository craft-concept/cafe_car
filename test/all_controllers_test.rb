require "test_helper"

class AllControllersTest < ActionDispatch::IntegrationTest
  def self.test_resources(name, scope: nil)
    controller = [*scope, *name].join("/")
    singular   = [*name].join("/").singularize

    test controller do
      get url_for(controller:, action: :index)
      assert_response :success

      get url_for(controller:, action: :new)
      assert_response :success

      id = create(singular)

      get url_for(controller:, action: :show, id:)
      assert_response :success

      get url_for(controller:, action: :edit, id:)
      assert_response :success

      delete url_for(controller:, action: :destroy, id:)
      assert_redirected_to url_for(controller:, action: :index)
    end
  end

  with_options scope: :admin do
    test_resources :articles
    test_resources :clients
    test_resources :invoices
    # test_resources :notes
    # test_resources :users
  end
end

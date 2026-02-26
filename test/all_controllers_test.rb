require "test_helper"

class AllControllersTest < ActionDispatch::IntegrationTest
  def self.test_resources(name, scope: nil)
    controller = [*scope, *name].join("/")
    singular   = [*name].join("/").singularize

    test "#{controller}_index" do
      get url_for(controller:, action: :index)

      assert_response :success
    end

    test "#{controller}_create"  do
      params = {singular => build(singular).as_json}
      post(url_for(controller:, action: :create), params:)

      assert_response :redirect
    end

    test "#{controller}_new"  do
      get url_for(controller:, action: :new)

      assert_response :success
    end

    test "#{controller}_show"  do
      id = create(singular)

      get url_for(controller:, action: :show, id:)

      assert_response :success
    end

    test "#{controller}_edit"  do
      id = create(singular)
      get url_for(controller:, action: :edit, id:)

      assert_response :success
    end

    test "#{controller}_destroy"  do
      id = create(singular)
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

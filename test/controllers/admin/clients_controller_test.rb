require "test_helper"

class Admin::ClientsControllerTest < ActionDispatch::IntegrationTest
  test "clients index" do
    get "/admin/clients"
    assert_select 'h1', 'Clients'
  end

  test "missing params" do
    post "/admin/clients"
    assert_response :bad_request
  end

  test "validation errors" do
    post "/admin/clients", params: {client: {a: 1}}
    assert_response :unprocessable_content
    assert_select '.Field_Error', "can't be blank"
  end

  test "clients create" do
    post "/admin/clients", params: {client: {name: "Bob", owner_id: create(:user).id}}
    follow_redirect!
    assert_select 'h1', 'Bob'
  end

  test "client show" do
    client = create(:client)
    get url_for([:admin, client])
    assert_response :success
    assert_select "h1", client.name
  end
end

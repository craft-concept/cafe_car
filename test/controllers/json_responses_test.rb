require "test_helper"

# Exercises the advertised `respond_to :json` path. The controller's
# `_render_with_renderer_json` restricts the payload to the policy's
# `displayable_attributes` (plus `:id`), so these assert the JSON shape: ids are
# present, displayable columns are present, and non-displayable columns (here the
# raw `owner_id`, which the policy maps to the `owner` association) do not leak.
class JsonResponsesTest < ActionDispatch::IntegrationTest
  test "index renders a json array of displayable attributes" do
    owner = create(:user)
    create(:client, name: "Alpha", owner:)
    create(:client, name: "Beta", owner:)

    get "/admin/clients", as: :json

    assert_response :success
    assert_equal "application/json", response.media_type

    body = response.parsed_body
    assert_kind_of Array, body
    assert_equal 2, body.size

    body.each do |row|
      assert row["id"].present?, "each record exposes its id"
      assert_includes %w[Alpha Beta], row["name"]
      assert_equal %w[created_at id name status updated_at], row.keys.sort,
                   "only displayable attributes are serialized"
      refute row.key?("owner_id"), "non-displayable foreign key must not leak"
    end
  end

  test "show renders a single record's displayable attributes" do
    client = create(:client, name: "Gamma")

    get "/admin/clients/#{client.id}", as: :json

    assert_response :success
    assert_equal "application/json", response.media_type

    body = response.parsed_body
    assert_equal client.id, body["id"]
    assert_equal "Gamma", body["name"]
    refute body.key?("owner_id"), "non-displayable foreign key must not leak"
  end
end

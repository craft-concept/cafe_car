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

  test "show renders scalar displayable attributes without associations" do
    owner  = create(:user, password: "secret", password_confirmation: "secret")
    client = create(:client, name: "Gamma", owner:)
    create(:invoice, client:, sender: owner)

    get "/admin/clients/#{client.id}", as: :json

    assert_response :success
    assert_equal "application/json", response.media_type

    body = response.parsed_body
    assert_equal client.id, body["id"]
    assert_equal "Gamma", body["name"]
    assert_equal %w[created_at id name status updated_at], body.keys.sort,
                 "only scalar displayable attributes are serialized"
    refute body.key?("owner_id"), "non-displayable foreign key must not leak"
    refute body.key?("owner"), "belongs_to association must not be serialized by default"
    refute body.key?("invoices"), "has_many association must not be serialized by default"
    refute_includes response.body, "password_digest"
  end
end

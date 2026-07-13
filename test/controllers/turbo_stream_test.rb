require "test_helper"

# Exercises the advertised `respond_to :turbo_stream` path end-to-end. The
# create/update actions render the engine's `*.turbo_stream.haml` templates;
# these assert the host actually gets a valid `<turbo-stream>` document with the
# correct content type back.
class TurboStreamTest < ActionDispatch::IntegrationTest
  TURBO = { "Accept" => "text/vnd.turbo-stream.html" }.freeze

  test "create responds with a turbo stream" do
    owner = sign_in

    post "/admin/clients",
         params: { client: { name: "Turbo Inc", owner_id: owner.id } },
         headers: TURBO

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match(/<turbo-stream\b/, response.body)
    assert Client.exists?(name: "Turbo Inc")
  end

  test "update responds with a turbo stream" do
    client = create(:client)

    patch "/admin/clients/#{client.id}",
          params: { client: { name: "Renamed Co" } },
          headers: TURBO

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match(/<turbo-stream\b/, response.body)
    assert_equal "Renamed Co", client.reload.name
  end

  test "format param also negotiates turbo stream" do
    owner = sign_in

    post "/admin/clients",
         params: { client: { name: "Format Co", owner_id: owner.id }, format: :turbo_stream }

    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match(/<turbo-stream\b/, response.body)
  end
end

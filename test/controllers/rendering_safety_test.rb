require "test_helper"

class RenderingSafetyTest < ActionDispatch::IntegrationTest
  setup { create(:client) }

  test "an unknown index view falls back to the default view" do
    get "/admin/clients", params: { view: "unknown" }

    assert_response :success
    assert_select ".Table"
  end

  test "the debug partial cannot be selected as an index view" do
    in_environment("development") do
      get "/admin/clients", params: { view: "debug" }
    end

    assert_response :success
    assert_select ".Table"
    assert_select ".Card_Title", text: "Debug", count: 0
  end

  test "debug output is disabled in production" do
    in_environment("production") do
      get "/admin/clients", params: { debug: true }
    end

    assert_response :success
    assert_select ".Card_Title", text: "Debug", count: 0
  end

  test "debug output is disabled for remote development requests" do
    in_environment("development") do
      get "/admin/clients", params: { debug: true }, headers: { "REMOTE_ADDR" => "203.0.113.1" }
    end

    assert_response :success
    assert_select ".Card_Title", text: "Debug", count: 0
  end

  private

  def in_environment(name)
    original = Rails.env
    Rails.env = name
    yield
  ensure
    Rails.env = original
  end
end

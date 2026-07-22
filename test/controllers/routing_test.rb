require "test_helper"

# The `cafe_car` routes macro (CafeCar::Routing) is the ONLY way a resource
# gains CafeCar's endpoints (batch/options/member_action/collection_action).
# A plain `resources` must stay exactly Rails' routes — having cafe_car in the
# Gemfile must never widen a host resource — and `only:`/`except:` must narrow
# the CafeCar endpoints along with the RESTful ones.
class RoutingTest < ActiveSupport::TestCase
  test "a plain host `resources` gains no CafeCar endpoints" do
    routes = Rails.application.routes # passwords/denials are drawn with bare `resources`

    assert_nil recognize(routes, :post, "/passwords/batch")
    assert_nil recognize(routes, :post, "/denials/batch")
    assert_nil recognize(routes, :post, "/denials/1/actions/publish")
    assert_nil recognize(routes, :post, "/denials/actions/publish_all")
    # GET falls through to the dummy's pages catch-all, never DenialsController.
    assert_not_equal "denials", recognize(routes, :get, "/denials/options")&.dig(:controller)
  end

  test "`cafe_car` draws the four CafeCar endpoints" do
    routes = draw { cafe_car :articles }

    assert_equal "batch",   recognize(routes, :post, "/articles/batch")[:action]
    assert_equal "options", recognize(routes, :get,  "/articles/options")[:action]
    assert_equal({ controller: "articles", action: "member_action", id: "1", member_action: "publish" },
                 recognize(routes, :post, "/articles/1/actions/publish"))
    assert_equal({ controller: "articles", action: "collection_action", collection_action: "publish_all" },
                 recognize(routes, :post, "/articles/actions/publish_all"))
  end

  test "`only:` narrows the CafeCar endpoints along with the RESTful ones" do
    routes = draw { cafe_car :articles, only: %i[index show] }

    assert recognize(routes, :get, "/articles")
    assert recognize(routes, :get, "/articles/1")
    assert_nil recognize(routes, :post, "/articles") # create isn't drawn either
    assert_nil recognize(routes, :post, "/articles/batch")
    assert_nil recognize(routes, :post, "/articles/1/actions/publish")
    assert_nil recognize(routes, :post, "/articles/actions/publish_all")
    # GET /articles/options can only match `show` (id: "options"), never #options.
    assert_equal "show", recognize(routes, :get, "/articles/options")[:action]
  end

  test "`except:` filters CafeCar endpoints by name" do
    routes = draw { cafe_car :articles, except: %i[destroy options] }

    assert recognize(routes, :post, "/articles/batch")
    assert_nil recognize(routes, :delete, "/articles/1")
    # GET /articles/options can only match `show` (id: "options"), never #options.
    assert_equal "show", recognize(routes, :get, "/articles/options")[:action]
  end

  test "a block passes through to `resources`" do
    routes = draw { cafe_car(:articles) { get :preview, on: :member } }

    assert_equal "preview", recognize(routes, :get, "/articles/1/preview")[:action]
  end

  private

  def draw(&block) = ActionDispatch::Routing::RouteSet.new.tap { _1.draw(&block) }

  def recognize(routes, method, path)
    routes.recognize_path(path, method:)
  rescue ActionController::RoutingError
    nil
  end
end

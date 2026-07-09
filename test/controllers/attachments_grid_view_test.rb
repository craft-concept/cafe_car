require "test_helper"

# Effect-level coverage of the attachments index in its default "grid" view.
# The grid item renders each record's logo via `logo(href: object)`, but the
# ActiveStorage attachment presenter had narrowed `logo` to zero-arity
# (`def logo = self`), so passing `href:` raised
# `ArgumentError (given 1, expected 0)` and crashed the page — but only in the
# grid view, which is why the table-view smoke check never caught it.
class AttachmentsGridViewTest < ActionDispatch::IntegrationTest
  setup { sign_in }

  test "the attachments grid renders a card per attachment, image and all" do
    create_list(:user, 3) # the user factory attaches a PNG avatar to each

    get "/admin/active_storage/attachments", params: { view: "grid" }

    assert_response :success
    # Scoped to the grid: the index aside renders its own Card (the filter panel).
    cards = Nokogiri::HTML5(response.body).css(".Grid .Card")
    assert_equal ActiveStorage::Attachment.count, cards.size
    assert cards.css("img").any?, "each attachment card renders its image"
  end
end

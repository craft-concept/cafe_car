require "test_helper"

class LocalizedCopyTest < ActionDispatch::IntegrationTest
  setup { @user = sign_in }

  test "index tools and filtered result copy use shipped translations" do
    create(:article, title: "Needle", author: @user)

    get "/admin/articles", params: { "title~" => "Needle" }

    assert_response :success
    %w[Grid\ View Table\ View Chart\ View Download\ CSV].each do |tip|
      assert_select "[data-tip=?]", tip, 1
    end
    assert_select ".center", text: /matching your filters\./
    assert_select ".center a", text: "View all"
  end

  test "record cards and nested controls use shipped translations" do
    article = create(:article, author: @user)

    get "/admin/articles/#{article.id}"

    assert_response :success
    assert_select ".Card_Title", text: "Actions"
    assert_select ".Card_Title", text: "Notes"

    get "/admin/invoices/new"

    assert_response :success
    assert_select "[data-nested-add]", text: "+ Line items attributes"
    assert_select "[data-nested-remove]", text: "Remove"
  end

  test "validation fallback and batch notice use shipped translations" do
    post "/admin/clients", params: { client: { name: "", owner_id: @user.id } }

    assert_response :unprocessable_content
    assert_select ".Error", text: /Correct the errors above\./

    article = create(:article, author: @user)
    post "/admin/articles/batch", params: { bulk_action: "destroy", ids: [ article.id ] }

    assert_redirected_to "/admin/articles"
    assert_equal "Delete 1 article", flash[:success]
  end
end

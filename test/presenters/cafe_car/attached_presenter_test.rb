require "test_helper"

module CafeCar
  # Attachments render through their type's presenter: a `has_one_attached`
  # value shows a thumbnail for images and a filename link for other files;
  # a `has_many_attached` value shows a compact, counted list of the same —
  # never the raw `#<ActiveStorage::Attached::Many...>` inspect string.
  class AttachedPresenterTest < ActionView::TestCase
    helper CafeCar::Helpers

    setup do
      ::ActiveStorage::Current.url_options = { host: "http://example.com" }
      view.singleton_class.define_method(:policy) { |object| Pundit.policy!(nil, object) }
    end

    def show(object, method) = view.present(object).show(method).to_s

    def attach_documents(user, *names)
      names.each do |name|
        user.documents.attach(io: file_fixture(name).open, filename: name, content_type: "text/plain")
      end
    end

    test "attached values dispatch to the attached presenters" do
      assert_equal ActiveStorage::Attached::OnePresenter,  Presenter.find(::ActiveStorage::Attached::One)
      assert_equal ActiveStorage::Attached::ManyPresenter, Presenter.find(::ActiveStorage::Attached::Many)
    end

    test "an image attachment renders a thumbnail" do
      user = create(:user) # factory attaches a PNG avatar

      assert_match %r{\A<img }, show(user, :avatar)
    end

    test "a non-image attachment renders a filename link" do
      user = create(:user)
      user.avatar.attach(io: file_fixture("doc1.txt").open, filename: "doc1.txt", content_type: "text/plain")

      assert_match %r{\A<a href=".+">doc1\.txt</a>\z}, show(user, :avatar)
    end

    test "has_many_attached renders a counted list of file links, not inspect output" do
      user = create(:user)
      attach_documents(user, "doc1.txt", "doc2.txt")

      html = show(user, :documents)

      assert_match "doc1.txt", html
      assert_match "doc2.txt", html
      assert_match "2 total", html
      refute_match "Attached::Many", html
    end

    test "blank attachments render blank" do
      user = create(:user)

      assert_equal "", show(User.new(name: "Blank"), :avatar)
      assert_equal "(none)", show(user, :documents)
    end

    test "non-attachment attributes are unaffected" do
      user = create(:user, name: "Priscilla")

      assert_equal "Priscilla", show(user, :name)
    end
  end
end

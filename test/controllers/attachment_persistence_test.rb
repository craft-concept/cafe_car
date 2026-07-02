require "test_helper"

# EFFECT-level coverage for `has_many_attached` forms. The README advertises it,
# but a scalar strong-params permit used to drop the uploaded array, so a
# multi-file field silently persisted at most one file. This asserts the whole
# array round-trips: submit two files, expect two attachments on the record.
class AttachmentPersistenceTest < ActionDispatch::IntegrationTest
  setup { @user = sign_in }

  def upload(name) = fixture_file_upload(name, "text/plain")

  test "updating a user persists every file in a has_many_attached field" do
    patch url_for(controller: "admin/users", action: :update, id: @user.id), params: {
      user: { documents: [ upload("doc1.txt"), upload("doc2.txt") ] }
    }

    assert_equal 2, @user.reload.documents.count
    assert_equal %w[doc1.txt doc2.txt], @user.documents.map(&:filename).map(&:to_s).sort
  end

  test "a single has_many_attached upload still persists" do
    patch url_for(controller: "admin/users", action: :update, id: @user.id), params: {
      user: { documents: [ upload("doc1.txt") ] }
    }

    assert_equal 1, @user.reload.documents.count
  end
end

require "test_helper"

# `default_view` is a per-controller setting backed by a class_attribute, so a
# subclass inherits its parent's value and can override it without leaking the
# override back up. A bare class ivar (the previous implementation) would not
# carry across subclassing — a subclass would silently fall back to "table".
class DefaultViewTest < ActiveSupport::TestCase
  # Admin::AttachmentsController sets `default_view :grid` (see the dummy app).
  test "a subclass inherits the parent's default_view and can override it" do
    assert_equal "grid", Admin::AttachmentsController.default_view

    subclass = Class.new(Admin::AttachmentsController)
    assert_equal "grid", subclass.default_view, "subclass should inherit :grid"

    subclass.default_view :table
    assert_equal "table", subclass.default_view, "subclass can override"
    assert_equal "grid", Admin::AttachmentsController.default_view,
      "the subclass override must not leak back to the parent"
  end
end

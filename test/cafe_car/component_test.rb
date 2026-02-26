require "test_helper"

class ComponentTest < ActionView::TestCase
  test "capture return" do
    assert_equal "yes", capture { "yes" }
  end

  test "capture concat" do
    assert_equal "yesyes", capture { concat "yes"; concat "yes" }
  end

  test "capture ignore return when concat" do
    assert_equal "yes", capture { concat "yes"; "no" }
  end

  test "capture nested" do
    assert_equal "yes", capture { capture { "yes" } }
    assert_equal "yes", capture { capture { concat "yes"; "no" } }
    assert_equal "abc", capture { bc = capture { concat ?b; concat ?c }; concat ?a; concat bc }
  end
end

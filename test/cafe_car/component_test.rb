require "test_helper"

class ComponentTest < ActionView::TestCase
  test "capture" do
    assert_equal "yes", capture { "yes" }
    assert_equal "yesyes", capture { concat "yes"; concat "yes" }
    assert_equal "yes", capture { concat "yes"; "no" }
    assert_equal "yes", capture { capture { "yes" } }
    assert_equal "yes", capture { capture { concat "yes"; "no" } }
    assert_equal "abc", capture { bc = capture { concat ?b; concat ?c }; concat ?a; concat bc }
  end
end

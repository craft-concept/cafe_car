require "test_helper"

class CafeCar::VendorAssetsTest < ActiveSupport::TestCase
  test "vendored Tom Select records its version, license, and source" do
    source = CafeCar::Engine.root.join("app/javascript/tom-select.complete.min.js").read.lines.first(6).join

    assert_includes source, "Tom Select v2.4.3"
    assert_includes source, "Apache License, Version 2.0"
    assert_includes source, "https://github.com/orchidjs/tom-select/releases/tag/v2.4.3"
  end
end

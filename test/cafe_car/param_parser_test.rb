require "test_helper"

module CafeCar
  class ParamParserTest < ActiveSupport::TestCase
    test "handles invalid range string" do
      parser = ParamParser.new({ "a" => "1..2..3" })

      assert_equal "1..2..3", parser.parsed[:a]
    end

    test "parses valid ranges" do
      parser = ParamParser.new({ "a" => "1..2", "b" => "3...5" })

      assert_equal "1".."2", parser.parsed[:a]
      assert_equal "3"..."5", parser.parsed[:b]
    end

    test "leaves structured-looking request values as literals" do
      parser = ParamParser.new({ "a" => "{broken", "b" => '["x"]', "c" => "$User.name" })

      assert_equal "{broken", parser.parsed[:a]
      assert_equal '["x"]', parser.parsed[:b]
      assert_equal "$User.name", parser.parsed[:c]
    end

    test "nests shallow dotted keys" do
      parser = ParamParser.new({ "price.min" => "1", "price.max" => "9" })

      assert_equal({ "min" => "1", "max" => "9" }, parser.parsed[:price])
    end

    test "nests a key up to the depth cap" do
      key = Array.new(ParamParser::MAX_DEPTH, "a").join(".")

      assert_nothing_raised { ParamParser.new({ key => "1" }).parsed }
    end

    test "rejects a dotted key deeper than the cap instead of overflowing the stack" do
      key = Array.new(ParamParser::MAX_DEPTH + 1, "a").join(".")

      assert_raises(ActionController::BadRequest) { ParamParser.new({ key => "1" }).parsed }
    end
  end
end

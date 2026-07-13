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
  end
end

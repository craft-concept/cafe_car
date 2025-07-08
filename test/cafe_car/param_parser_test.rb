require "test_helper"

module CafeCar
  class ParamParserTest < ActiveSupport::TestCase
    test "handles invalid range string" do
      parser = ParamParser.new({"a" => "1..2..3"})
      assert_equal "1..2..3", parser.parsed[:a]
    end

    test "parses valid ranges" do
      parser = ParamParser.new({"a" => "1..2", "b" => "3...5"})
      assert_equal "1".."2", parser.parsed[:a]
      assert_equal "3"..."5", parser.parsed[:b]
    end
  end
end

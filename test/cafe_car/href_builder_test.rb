require "test_helper"

module CafeCar
  class HrefBuilderTest < ActiveSupport::TestCase
    test "route key calculation" do
      href = HrefBuilder.new(PaperTrail::Version.new)
      assert_equal [:paper_trail_versions], href.expanded_parts
    end

    test "namespace truncation" do
      obj = Object.new
      href = HrefBuilder.new(:b, obj, :c, namespace: [:a, :b])
      assert_equal [:b, obj, :c], href.parts
      assert_equal [:a, :b], href.namespace

      assert_equal [:b, :object, :c], href.expanded_parts

      assert_equal [:a], href.collapsed_namespace
    end
  end
end

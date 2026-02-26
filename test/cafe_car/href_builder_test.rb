require "test_helper"

module CafeCar
  class HrefBuilderTest < ActiveSupport::TestCase
    test "route key calculation" do
      href = HrefBuilder.new(PaperTrail::Version.new)

      assert_equal [:paper_trail, :versions], href.expanded_parts

      href = HrefBuilder.new(PaperTrail::Version.new, namespace: [:paper_trail])

      assert_equal [:paper_trail, :versions], href.expanded_parts
    end

    test "parts" do
      href = HrefBuilder.new(:a, :b)

      assert_equal [:a, :b], href.parts
    end

    test "namespace" do
      href = HrefBuilder.new(:c, :d, namespace: [:a, :b])

      assert_equal [:a, :b], href.namespace
    end

    test "namespace truncation" do
      obj = Object.new
      href = HrefBuilder.new(:b, obj, :c, namespace: [:a, :b])

      assert_equal [:b, :object, :c], href.expanded_parts

      assert_equal [:a], href.collapsed_namespace
    end
  end
end

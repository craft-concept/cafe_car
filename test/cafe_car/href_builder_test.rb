require "test_helper"

module CafeCar
  class HrefBuilderTest < ActiveSupport::TestCase
    # Minimal template: knows the given route helpers, and url_for echoes its
    # parts after raising NoMethodError when the polymorphic helper is missing —
    # the behavior the pop-and-retry loop in #to_s rescues.
    Template = Struct.new(:helpers) do
      def respond_to?(name, _priv = false) = helpers.include?(name.to_sym) || super

      def url_for(parts)
        helper = parts.filter_map { route_key(_1) }.join("_") + "_path"
        raise NoMethodError, helper unless respond_to?(helper)
        parts
      end

      def route_key(part) = part.is_a?(Symbol) ? part : (part.class.model_name.route_key unless part.is_a?(Hash))
    end

    test "a record keeps routing polymorphically when its namespaced plural helper exists" do
      session  = Session.new
      template = Template.new(%i[admin_sessions_path session_path])

      assert_equal [ :admin, session, {} ],
                   HrefBuilder.new(session, namespace: [ :admin ], template:).to_s
    end

    test "a record falls back to its singular route key when only that helper exists" do
      session  = Session.new
      template = Template.new(%i[session_path])

      assert_equal [ :session, {} ], HrefBuilder.new(session, template:).to_s
    end

    test "popping a namespace re-probes the singular-resource fallback" do
      session  = Session.new
      template = Template.new(%i[session_path])

      assert_equal [ :session, {} ],
                   HrefBuilder.new(session, namespace: [ :admin ], template:).to_s
    end

    test "route key calculation" do
      href = HrefBuilder.new(PaperTrail::Version.new)

      assert_equal [ :paper_trail, :versions ], href.expanded_parts

      href = HrefBuilder.new(PaperTrail::Version.new, namespace: [ :paper_trail ])

      assert_equal [ :paper_trail, :versions ], href.expanded_parts
    end

    test "parts" do
      href = HrefBuilder.new(:a, :b)

      assert_equal [ :a, :b ], href.parts
    end

    test "namespace" do
      href = HrefBuilder.new(:c, :d, namespace: [ :a, :b ])

      assert_equal [ :a, :b ], href.namespace
    end

    test "namespace truncation" do
      obj = Object.new
      href = HrefBuilder.new(:b, obj, :c, namespace: [ :a, :b ])

      assert_equal [ :b, :object, :c ], href.expanded_parts

      assert_equal [ :a ], href.collapsed_namespace
    end
  end
end

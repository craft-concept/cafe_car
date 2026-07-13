require "test_helper"

module CafeCar
  # `policy.attributes` is the consolidated read surface for a policy's attribute
  # sets and custom-action lists. Each reader derives from a host-overridable
  # `permitted_*` method, so these prove the fold is behavior-preserving: a host
  # override of the public method still flows through `attributes.*`.
  class PolicyAttributesTest < ActiveSupport::TestCase
    def policy(record, klass = ArticlePolicy) = klass.new(build(:user), record)

    test "attributes.actions reads the policy's host-overridden action lists" do
      p = policy(Article.new)

      assert_equal p.permitted_bulk_actions,       p.attributes.actions.bulk
      assert_equal p.permitted_member_actions,     p.attributes.actions.member
      assert_equal p.permitted_collection_actions, p.attributes.actions.collection
      # ArticlePolicy overrides these away from the ApplicationPolicy defaults.
      assert_equal %i[publish destroy], p.attributes.actions.bulk
      assert_equal %i[publish],         p.attributes.actions.member
      assert_equal %i[publish_all],     p.attributes.actions.collection
    end

    test "attributes.filterable reads the policy's permitted_filters" do
      p = policy(Article.new)
      assert_equal p.permitted_filters, p.attributes.filterable
    end

    test "a host override of permitted_filters flows through attributes.filterable" do
      narrowed = Class.new(ArticlePolicy) { def permitted_filters = %i[title] }
      assert_equal %i[title], narrowed.new(build(:user), Article.new).attributes.filterable
    end

    test "attributes.displayable resolves foreign keys to associations and drops id" do
      displayable = policy(Article.new).attributes.displayable

      assert_includes     displayable, :title
      assert_includes     displayable, :author  # author_id → :author
      assert_not_includes displayable, :author_id
      assert_not_includes displayable, :id
    end

    test "host overrides of displayed attribute declarations flow through attributes" do
      narrowed = Class.new(ArticlePolicy) do
        def displayable_attributes = super - %i[summary]
        def listable_attributes = super - %i[summary]
      end
      attributes = policy(Article.new, narrowed).attributes

      assert_not_includes attributes.displayable, :summary
      assert_not_includes attributes.listable, :summary
    end

    test "attributes.editable lists the permitted attributes' input keys" do
      assert_includes policy(Article.new).attributes.editable, :title
    end

    test "attributes.listable lists the model's listable columns" do
      assert_includes policy(Article.new).attributes.listable, :title
    end
  end
end

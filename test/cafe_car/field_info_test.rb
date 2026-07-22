require "test_helper"

module CafeCar
  # Guards the `FieldInfo#type` resolution chain. `nested_attributes_type` sits
  # at the *front* of the chain, so these prove it only wins for associations
  # that actually declare `accepts_nested_attributes_for` and that every other
  # association/attribute still resolves to the same type it did before.
  class FieldInfoTest < ActiveSupport::TestCase
    def info(model, method) = FieldInfo.new(model:, method:)

    test "has_many with accepts_nested_attributes_for resolves to :nested" do
      assert_equal :nested, info(Invoice, :line_items).type
    end

    test "nested type maps to the fields_for input" do
      assert_equal :fields_for, info(Invoice, :line_items).input
    end

    test "belongs_to still resolves to :belongs_to (and an association input)" do
      field = info(Invoice, :client)

      assert_equal :belongs_to, field.type
      assert_equal :association, field.input
    end

    test "plain has_many without nested attributes still resolves to :has_many" do
      assert_equal :has_many, info(Client, :invoices).type
    end

    test "plain column attributes are unaffected" do
      assert_equal :string, info(Client, :name).type
    end

    test "nested_attributes_type is nil unless the association opts in" do
      assert_nil info(Invoice, :client).nested_attributes_type
      assert_nil info(Client, :invoices).nested_attributes_type
      assert_nil info(Client, :name).nested_attributes_type
      assert_equal :nested, info(Invoice, :line_items).nested_attributes_type
    end

    # `enum_type` sits ahead of `attribute_type`, so an ActiveRecord enum wins
    # over its raw backing column and the UI can render its declared values.
    test "enum column resolves to :enum, not its raw column type" do
      field = info(Client, :status)

      assert_equal :enum, field.type
      assert_equal :enum, field.input
    end

    test "enum exposes its declared values" do
      assert_equal %w[active archived], info(Client, :status).values
    end

    test "enum_type is nil for non-enum attributes" do
      assert_nil info(Client, :name).enum_type
      assert_nil info(Invoice, :number).enum_type
    end

    # `badge?` is the status-badge convention: an ActiveRecord enum, or a
    # string column named status/state, renders as a Badge pill by default.
    test "badge? is true for enums and string status columns" do
      assert info(Client, :status).badge?
      assert info(User, :status).badge?
    end

    test "badge? is false for everything else" do
      refute info(Client, :name).badge?
      refute info(Invoice, :number).badge?
      refute info(Invoice, :paid).badge?
    end

    # A `belongs_to` select must not load the whole target table — `collection`
    # caps the rows at `CafeCar.max_collection_options` on the SQL relation, so a
    # 10k-row association renders at most that many `<option>`s.
    test "collection is capped at CafeCar.max_collection_options" do
      owner = User.create!(name: "Owner", email: "owner@example.com", password: "secret123")
      5.times { |i| Client.create!(name: "Client #{i}", owner:) }

      with_max_collection_options(3) do
        assert_equal 3, info(Invoice, :client).collection.to_a.size
      end
    end

    private

    def with_max_collection_options(cap)
      original = CafeCar.max_collection_options
      CafeCar.max_collection_options = cap
      yield
    ensure
      CafeCar.max_collection_options = original
    end
  end
end

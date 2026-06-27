require "test_helper"
require "generators/cafe_car/notes/notes_generator"

class CafeCar::NotesGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::NotesGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # The notes generator delegates the Note policy + controller to subprocess
  # `rails generate` calls, which need a host bin/rails. Skip those delegations
  # so the test covers what this generator creates directly: the migration,
  # model, and concern.
  setup { CafeCar::NotesGenerator.prepend(SkipDelegatedGenerators) }

  module SkipDelegatedGenerators
    def generate(*) = nil
  end

  test "creates the notes migration" do
    run_generator

    assert_migration "db/migrate/create_notes.rb" do |migration|
      assert_match(/create_table :notes/, migration)
      assert_match(/t\.references :notable, polymorphic: true/, migration)
      assert_match(/t\.references :author/, migration)
      assert_match(/t\.text :body/, migration)
    end
  end

  test "creates the Note model" do
    run_generator

    assert_file "app/models/note.rb" do |model|
      assert_match(/class Note < ApplicationRecord/, model)
      assert_match(/belongs_to :notable, polymorphic: true/, model)
      assert_match(/belongs_to :author, class_name: "User"/, model)
      assert_match(/validates :body, presence: true/, model)
    end
  end

  test "creates the Notable concern" do
    run_generator

    assert_file "app/models/concerns/notable.rb" do |concern|
      assert_match(/module Notable/, concern)
      assert_match(/has_many :notes, as: :notable/, concern)
    end
  end
end

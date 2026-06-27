require "test_helper"
require "generators/cafe_car/notes/notes_generator"
require_relative "host_skeleton"

class CafeCar::NotesGeneratorTest < Rails::Generators::TestCase
  # Stub the policy/controller delegations (covered by the inline test below) so
  # these specs focus on what notes creates directly: the migration, model, and
  # concern. Stubbing on a subclass keeps it out of the inline test.
  class DirectNotesGenerator < CafeCar::NotesGenerator
    source_root CafeCar::NotesGenerator.source_root

    private

    def generate(*) = nil
  end

  tests DirectNotesGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

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

# The Note policy and controller are delegated *inline* (like the resource
# generator), so they land in the destination without shelling out to a host
# bin/rails. --force lets the Note policy skip the collision check, since the
# dummy app already defines NotePolicy.
class CafeCar::NotesGeneratorInlineTest < Rails::Generators::TestCase
  include HostSkeleton

  tests CafeCar::NotesGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination
  setup :build_host_skeleton

  test "delegates the Note policy and controller into the destination" do
    run_generator [ "--force" ]

    assert_file "app/policies/note_policy.rb" do |policy|
      assert_match(/class NotePolicy < ApplicationPolicy/, policy)
    end
    assert_file "app/controllers/admin/notes_controller.rb" do |controller|
      assert_match(/class NotesController < ApplicationController/, controller)
    end
  end
end

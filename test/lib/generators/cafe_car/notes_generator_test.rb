require "test_helper"
require "generators/cafe_car/notes/notes_generator"

class CafeCar::NotesGeneratorTest < Rails::Generators::TestCase
  tests CafeCar::NotesGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end

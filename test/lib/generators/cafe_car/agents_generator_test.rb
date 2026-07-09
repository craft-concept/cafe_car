require "test_helper"
require "generators/cafe_car/agents/agents_generator"
require_relative "host_skeleton"

class CafeCar::AgentsGeneratorTest < Rails::Generators::TestCase
  include HostSkeleton # for `write`; no skeleton needed — the generator creates everything

  tests CafeCar::AgentsGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  test "copies the skill into .claude and mirrors it to .agents" do
    run_generator

    assert_file ".claude/skills/cafe_car/SKILL.md", /composable view extension/
    assert_file ".claude/skills/cafe_car/references/policies.md"
    assert_file ".agents/skills/cafe_car/SKILL.md", /composable view extension/
    assert_file ".agents/skills/cafe_car/references/policies.md"
  end

  test "creates AGENTS.md with the marked block when absent" do
    run_generator

    assert_file "AGENTS.md" do |md|
      assert_match "<!-- cafe_car:start -->", md
      assert_match ".claude/skills/cafe_car/SKILL.md", md
      assert_match "<!-- cafe_car:end -->", md
    end
  end

  test "appends the block to an existing AGENTS.md without touching its content" do
    write "AGENTS.md", "# House rules\n\nBe kind.\n"
    run_generator

    assert_file "AGENTS.md" do |md|
      assert_match "Be kind.", md
      assert_match "<!-- cafe_car:start -->", md
    end
  end

  test "re-running replaces the block instead of duplicating it" do
    2.times { run_generator }

    assert_file "AGENTS.md" do |md|
      assert_equal 1, md.scan("<!-- cafe_car:start -->").count
    end
  end

  test "re-running refreshes a stale block in place, leaving surrounding content alone" do
    write "AGENTS.md", <<~MD
      above

      <!-- cafe_car:start -->
      old text
      <!-- cafe_car:end -->

      below
    MD
    run_generator

    assert_file "AGENTS.md" do |md|
      assert_match "above", md
      assert_match "below", md
      refute_match "old text", md
      assert_match ".claude/skills/cafe_car/SKILL.md", md
      assert_equal 1, md.scan("<!-- cafe_car:start -->").count
    end
  end
end

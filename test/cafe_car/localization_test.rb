require "test_helper"

class CafeCar::LocalizationTest < ActiveSupport::TestCase
  COPY_PATTERNS = {
    component_attribute: /(?:title|tip|label|placeholder):\s*["'][A-Z][^"']*["']/,
    submit_status: /turbo_submits_with:\s*["']/,
    button_text: /^\s*%button[^=\n]*\}\s+[A-Z]/,
    text_node: /^\s+[A-Z][A-Za-z ]+[.!]?$/
  }.freeze

  test "production templates do not hardcode common user-facing copy" do
    offenses = templates.flat_map do |path|
      source = path.read.lines.reject { _1.lstrip.start_with?("-#") }.join

      COPY_PATTERNS.filter_map do |kind, pattern|
        "#{path.relative_path_from(root)} has hardcoded #{kind} copy" if source.match?(pattern)
      end
    end

    assert_empty offenses, offenses.join("\n")
  end

  test "shipped locale contains the shared UI copy" do
    keys = %w[
      helpers.card.actions helpers.card.notes helpers.errors.correct_above
      helpers.filter.matching helpers.filter.view_all helpers.nested.add
      helpers.nested.remove helpers.saving helpers.view.chart
      helpers.view.download_csv helpers.view.grid helpers.view.table
      flashes.batch_action table.created table.select_row
    ]

    keys.each { refute_match(/Translation missing/, I18n.t(_1, count: 2, field: "Items", action: "Delete", models: "items", time: "now")) }
  end

  private

  def root = Rails.root.join("../..").expand_path

  def templates
    root.glob("app/views/**/*.{haml,erb}").reject { _1.to_s.include?("/examples/") }
  end
end

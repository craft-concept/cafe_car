class CafeCar::AgentsGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../..", __dir__)

  BLOCK = <<~MD.freeze
    <!-- cafe_car:start -->
    This app uses the **cafe_car** gem. Before hand-writing any view, form, table, or
    value-formatting code for a model — customer-facing or admin — read
    `.claude/skills/cafe_car/SKILL.md`. CafeCar's pieces (presenters, form builder, components,
    policy-driven rendering) work on any page, and pointing a controller at a model renders a
    whole CRUD surface from the Pundit policy (filtering, sorting, turbo-streams, CSV) for free.
    <!-- cafe_car:end -->
  MD

  MARKED_BLOCK = /^<!-- cafe_car:start -->.*?<!-- cafe_car:end -->/m

  def copy_skill
    directory "skills/cafe_car", ".claude/skills/cafe_car", force: true
    directory "skills/cafe_car", ".agents/skills/cafe_car", force: true
  end

  def update_agents_md
    if agents_md&.match?(MARKED_BLOCK)
      gsub_file "AGENTS.md", MARKED_BLOCK, BLOCK.chomp
    elsif agents_md
      append_to_file "AGENTS.md", "\n#{BLOCK}"
    else
      create_file "AGENTS.md", BLOCK
    end
  end

  def post_install
    say <<~MSG

      CafeCar agent docs installed:
        .claude/skills/cafe_car/   Claude Code skill
        .agents/skills/cafe_car/   mirror for Codex, Copilot, and other agents
        AGENTS.md                  pointer block (re-runs replace only the marked block)

      Optional, for your team:
        npx skills add craft-concept/cafe_car      # install the skill in any skills-aware tool
        https://gitmcp.io/craft-concept/cafe_car   # live CafeCar docs over MCP, zero setup
    MSG
  end

  private

  def agents_md
    path = File.join(destination_root, "AGENTS.md")
    File.read(path) if File.exist?(path)
  end
end

---
id: backport-operator-agent-roster
title: Backport missing operator agent roster (coder + review panel) from template
priority: P1
status: done
domain: Eng
created: 2026-07-01
blocked_on: none
---

> **Done 2026-07-01 (pass 62):** commit `39137447`, rake green. Added coder + review panel
> (graybeard, hipster, green-eyeshade, counsel, bullhorn, redteam) to `.claude/agents/`.
> Template files had no `{{VENTURE}}` placeholders (verbatim copies). Agent types now
> register live — the conductor can delegate to `coder` and convene a review board again.


**Discovered pass 62:** dispatching a `coder` builder failed — `Agent type 'coder' not found`.
My repo's `.claude/agents/` has only `conductor.md`, `designer.md`, `dream.md`, but my conductor
charter repeatedly references agents that don't exist locally:
- **`coder`** — my primary engineering/docs/config builder ("delegate the build to a coder").
- **the review panel** — `graybeard`, `hipster`, `green-eyeshade`, `counsel`, `bullhorn`,
  `redteam` ("Use the review panel for audits — run a board").

All seven exist in `~/code/holdco/templates/new-venture/.claude/agents/`. Backport them into
`.claude/agents/`, substituting `{{VENTURE}}` → `cafe_car`.

Do **NOT** copy the template's `operator.md` — this venture already customized that persona to
`conductor.md`. Only add the 7 missing builder/reviewer personas. Verify no `{{...}}` placeholders
remain. Run `bundle exec rake`, commit, push.

Rationale: without these, the conductor can't delegate to a coder or convene a review board — the
operating loop's two core delegation moves both fail. High-leverage self-repair.

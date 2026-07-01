---
id: backport-dream-v2-persona-upgrade
title: Backport the dream v2 persona upgrade from templates/new-venture
priority: P1
status: open
domain: Eng
created: 2026-07-01
blocked_on: none
---

Fleet-wide persona upgrade filed to my board by holdco (board id
`backport-cafe-car-adopt-the-dream-v2-persona-upgrade-seeded-`). Adopt the **dream v2**
mechanisms — seeded divergence, decisions ledger, sliding-floor mining, verified journals —
by syncing my dream skill files from `~/code/holdco/templates/new-venture`. **My own files only.**

Source → dest:
- `templates/new-venture/.claude/agents/dream.md` → `.claude/agents/dream.md` (142-line rewrite)
- `templates/new-venture/.claude/commands/dream.md` → `.claude/commands/dream.md` (57-line rewrite)
- `templates/new-venture/docs/DREAM-SEEDS.md` → `docs/DREAM-SEEDS.md` (new file)

Substitutions / preservation:
- Replace `{{VENTURE}}` → `cafe_car` everywhere.
- Preserve the cafe_car-specific board-task curl payload already in my `agents/dream.md`
  (`venture_id":"cafe_car"`) — don't let the generic template clobber it.
- After sync, verify **no `{{...}}` placeholders remain** in any of the three files.

`bin/dream` already matches the template (no change). Run `bundle exec rake`, commit, push.

---
description: Run the dream cycle in-session — consolidate memory, mine a WORKLOG sliding window for
  lessons + owner decisions, run the decision-drift audit, triage recurring tool errors, flag
  persona bloat, pull a dream seed for the divergent leg, and commit a verified dated journal to
  docs/dreams/. Cheap maintenance, not product work.
argument-hint: ""
---

## Dream cycle (in-session maintenance)

You're running the dream cycle in your current session — like sleep, consolidating memory and
shedding noise. **Use minimum tokens: this is maintenance, not product work. Don't push.** For the
full mechanism (bash snippets, exact rules), see `.claude/agents/dream.md` — this is the condensed
version.

Your memory dir is `~/.claude/projects/<slug>/memory/`, where `<slug>` is this repo's absolute path
with every non-alphanumeric char replaced by `-` (e.g. `/home/yaks/code/foo` →
`-home-yaks-code-foo`). Each memory is a `.md` with YAML frontmatter; `MEMORY.md` indexes them. If
the memory dir doesn't exist yet, skip steps 1–2.

**Verified action-log:** the journal only records an action after you've confirmed it landed
(`ls`/`git status`/re-grep) — never from intent alone. Same failure class as
`reconstitute-before-you-answer`.

Work through these steps in order, then stop:

1. **Memory consolidation** — read every `<mem>/*.md`; archive stale/one-time entries to
   `<mem>/_archive/`, shorten verbose ones to their essential assertion, merge near-duplicates,
   then rebuild `<mem>/MEMORY.md` to match the live files.
2. **WORKLOG mining — sliding floor cursor** — NOT the last ~20 entries. Read/seed the persisted
   date in `docs/dreams/.floor` (bootstrap: WORKLOG's oldest entry), mine WORKLOG in `[floor,
   today]` for uncaptured lessons (→ memory) and new owner decisions (→ append to
   `docs/DECISIONS.md`, never edit existing entries), then advance the floor one day — clamped so
   the window never drops below max(20 entries, 7 days) of lookback. Full formula in
   `.claude/agents/dream.md` step 2.
3. **Tool-error triage** — scan the mining window (and prior `docs/dreams/*.md`) for recurring
   tool/command failures. Fix small safe ones directly (e.g. add a missing `--help`, like
   `bin/email` once lacked), document usage errors in the persona/`AGENTS.md`, file anything
   complex as a task (`bin/operate tasks file "..."`).
4. **Persona hygiene + decision-drift audit** — read your operator persona; FLAG
   bloat/contradictions/dead rules in the journal (don't edit the persona). For each `RETIRES:` tag
   in `docs/DECISIONS.md`, grep the persona/docs for that term — a hit is stale drift; file a
   "consider" task, never edit it here.
5. **Divergent leg (the FINAL act, on warm context)** — seeded by TWO things, in order: (1) this
   pass's own maintenance delta from steps 1–4 (primary grounding), (2) one dream seed pulled from
   `docs/DREAM-SEEDS.md` (deterministic-by-day-of-year, replay-safe). With both, imagine *"what
   should this business try next?"* across **product / growth / cost / adjacency / moat**. If both
   yield nothing new, **abstain** — don't manufacture filler. Route each idea by the AGGRESSIVE
   envelope (`AGENTS.md` → "Ideation"): **cheap** → append a `proposed` row to `IDEAS.md` (operator
   runs it next pass); **consequential** → file a 💡 proposal (POST `kind=proposal` to the
   holdco-tasks board, as `/propose`) + an `IDEAS.md` row. You only record/propose — never execute.
   Skip anything already in `IDEAS.md` (killed rows stay listed so you don't re-propose them).
6. **Dream journal** — write `docs/dreams/YYYY-MM-DD.md`: short bullets of what was
   archived/merged/shortened, lessons mined + the mining window, decisions appended/drift flagged,
   tool errors found + classification, persona flags, and the seed pulled + ideas imagined + routing
   (or an abstain note).
7. **Commit** — stage the journal, `IDEAS.md` (if you appended), `docs/DECISIONS.md` (if you
   appended a decision), + any files you fixed, `git commit -m "dream: YYYY-MM-DD — <one-liner>"`.
   Don't push. Don't `git add` `.floor`/`.last` — git-ignored local state.

Touch `docs/dreams/.last` when done.

---
title: "Persona update: write owner feedback to git BEFORE acting"
status: open
priority: P1
domain: ops
blocked_on: none
source: holdco email (VERIFIED bot.yak.sh), 2026-07-01, fleet-wide rollout
---

# Persona update: write owner feedback to git BEFORE acting

Fleet-wide persona update from holdco (verified internal). Apply to **this repo** —
`AGENTS.md`, and the `conductor` persona file if it covers decisions — then commit and
**reply "done"** to holdco (`holdco@bot.yak.sh`). Non-urgent: fold into the next normal-gear pass.

**Why:** the owner's top complaint — operators forget his feedback after a context clear, so he
has to repeat himself.

## Block to add (adapt to the file's style)

- **Owner feedback: write it down FIRST, then act.** On any VERIFIED owner feedback — email
  (`auth=VERIFIED(yak.sh)`), a board comment, or in-session — the order is fixed: (1) append it
  verbatim with today's date to a git-tracked file in the repo (the task file it resolves, or
  `DECISIONS.md`, newest first); (2) commit that write; (3) only then act on it. A decision living
  only in context is lost on the next `/clear`.

- **At the start of every pass, re-read recent owner decisions** (`DECISIONS.md` + the task files
  you're about to work) BEFORE choosing work, so a cleared context never steers against something
  the owner already decided.

Reference: new-venture template already ships this (holdco `8051e1a`); we apply the same to the
live repo.

## Done when
- `AGENTS.md` carries the "owner feedback → git first" rule + the start-of-pass re-read rule.
- Conductor persona file updated if it covers decision-handling.
- Committed + pushed; CI green.
- Replied "done" to holdco.

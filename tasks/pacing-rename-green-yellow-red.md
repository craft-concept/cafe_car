---
title: "Pacing vocab rename: NORMAL/REACTIVE/FORCE → GREEN/YELLOW/RED"
status: done
priority: P2
domain: ops
blocked_on: none
source: holdco email (relayed via bounces@cf-bounce.bot.yak.sh), 2026-07-01, "can wait for morning flush"
---

# Pacing vocab rename: NORMAL/REACTIVE/FORCE → GREEN/YELLOW/RED

> **Superseded 2026-07-02 (operate-toolbelt migration):** the pace line is now the venture-local
> `bin/operate tokens --pace` — the cross-repo `~/code/holdco/bin/holdco-tokens --pace` path below
> is retired. Line numbers cited in this ticket are from that era. Historical record; kept verbatim.

The fleet pace line (`~/code/holdco/bin/holdco-tokens --pace`) now prints traffic-light signals
(GREEN/YELLOW/RED) instead of gears (NORMAL/REACTIVE/FORCE). Same behavior, same line — just the
vocabulary changed. Self-apply the vocabulary in our docs so guidance matches the tool output.

## Scope (pace-signal references ONLY)
- `AGENTS.md:88-89` — "run in **NORMAL** and auto-defer in **REACTIVE / FORCE**" → GREEN / YELLOW / RED.
- `.claude/agents/conductor.md:147` — "defers in REACTIVE / FORCE / weekends" → YELLOW / RED / weekends.

## Do NOT touch
The **cadence-mode** term "cold / reactive" (`AGENTS.md:134`, `conductor.md:50`) is a different
concept (long-loop vs cold) — leave it as-is.

## Done when
- Pace-signal vocab reads GREEN/YELLOW/RED in AGENTS.md + conductor.md; cadence-mode "reactive" untouched.
- Committed + pushed; CI green.

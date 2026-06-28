---
id: brand-voice-guide-and-sweep
title: Author BRAND.md + one-time voice sweep of customer-visible copy
priority: P1
status: done
domain: Brand
created: 2026-06-27
blocked_on: none
---

Mirrors holdco board task `author-brand-md-voice-guide-route-all-customer-visible-copy-`
(filed 2026-06-27 22:24). Fleet anti-AI-slop voice-gate machinery shipped to this repo: the
`designer` persona now carries the anti-slop kit + voice-gate mode, there's a `BRAND.md` stub,
a `/copy` command, and an AGENTS voice-gate rule (`AGENTS.md` §"All customer-visible copy passes
the voice gate"). Two operator-owned follow-ups:

## Part 1 — Author BRAND.md — DONE (pass 26)

Filled the `BRAND.md` stub with CafeCar's actual voice, grounded in the shipped README + gem
description (not invented). Captured: audience (Rails devs who need an admin and won't hand-roll
CRUD), 5 behaviorally-defined voice adjectives (Rails-native, show-don't-claim, opinionated,
terse, unhyped), do/don't rules, an Always/Sometimes/Never lexicon, 8 on-voice/off-voice pairs
spanning headline → body → CTA → error → empty-state → email → social, and per-channel notes.
The universal slop list is intentionally NOT repeated (it lives in the designer persona).

## Part 2 — One-time voice sweep — PENDING designer-persona restart

Route all existing customer-visible copy through the voice gate (`/copy`) against the new
BRAND.md: README, gem description/summary, docs, demo/landing copy, product UI microcopy, error
strings, and any transactional/marketing email. From then on every customer-visible string ships
only after a `/copy` pass.

**Blocked:** the board task notes the designer persona changed, so a graceful operator restart is
needed to pick up the updated anti-slop kit — **holdco will sequence that restart**. Running the
sweep now risks using a stale persona. Hold part 2 until the restart lands, then run the sweep
(delegate to the refreshed `designer`) and route the README + gem description first (highest-traffic
customer-visible copy), then the rest.

**Unblock rationale (pass 32, 2026-06-28):** the staleness risk is structurally satisfied. A
one-shot `designer` subagent reads `.claude/agents/designer.md` fresh from disk on every spawn —
the persona file is timestamped today 09:01, after the anti-slop/voice-gate kit shipped. The
"restart" framing assumed a *persistent* designer teammate holding stale context; a fresh spawn
has none. Proceeding with the sweep via a fresh `designer`, README + gemspec description first.

## Part 2 — DONE (pass 32, 2026-06-28, commit `69d9bfc`)

Fresh `designer` swept all customer-visible copy against BRAND.md via the voice gate. Result was
a tight, surgical diff (the copy was already mostly on-voice):
- `config/locales/en.yml` flash strings: dropped exclamation-driven enthusiasm
  (`"created!"` → `"created."`) — BRAND's unhyped product-UI rule.
- `README.md:114`: `"a fully functional CRUD interface!"` → `"a working CRUD interface."` —
  removed inflated adjective + lone prose exclamation.
- Verified already on-voice and left byte-for-byte: gemspec summary/description, README intro +
  feature bullets, `docs/index.md`, `marketing/*` launch/syndication copy, remaining locale
  strings. No "Oops"/journey-speak found anywhere.
- `rake` green (122 runs / 0 failures, brakeman 0 warnings), pushed to main.

From here every new customer-visible string ships only after a `/copy` pass (AGENTS voice-gate rule).

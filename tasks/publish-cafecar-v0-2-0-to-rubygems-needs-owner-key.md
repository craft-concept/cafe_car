---
id: publish-cafecar-v0-2-0-to-rubygems-needs-owner-key
title: Publish CafeCar v0.2.0 to RubyGems (needs owner key)
priority: P1
status: open
domain: Launch-blocking
created: '2026-06-30'
blocked_on: user
---

v0.2.0 is **release-ready on main** and everything is prepped except the publish itself, which
needs the owner's RubyGems API key. `gem push` is an un-unwindable external action — owner-gated.

_Migrated from the retired QUESTIONS.md (entry "📦 v0.2.0 is ready to publish", 2026-06-27)._

- `version.rb` is already at **0.2.0**; **33 commits** have landed since the published `v0.1.2` —
  opt-in sessions/auth, the `cafe_car` macro rename, **CSV export**, **turnkey keyword search**,
  nested-attributes forms, the Pundit-verification footgun fix, and security hardening.
- CI green, `rake` green, demo healthy, docs + `CHANGELOG [Unreleased]` current.
- **On owner go-ahead + key in env:** finalize the CHANGELOG `[Unreleased] → [0.2.0]` with the
  date, tag `v0.2.0`, and `gem push`. Until then it sits release-ready on main.
- Apply the minimal-floor risk-check before pushing even on a verified owner go-ahead — a
  `gem push` is irreversible.

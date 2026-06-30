---
id: publish-cafecar-v0-2-0-to-rubygems-needs-owner-key
title: Publish CafeCar v0.2.0 to RubyGems (needs owner key)
priority: P1
status: open
domain: Launch-blocking
created: '2026-06-30'
blocked_on: homelab
---

v0.2.0 is **release-ready on main** and everything is prepped except the publish itself, which
needs (1) a RubyGems publish credential and (2) explicit owner go-ahead. `gem push` is an
un-unwindable external action — the go-ahead stays owner-gated.

_Migrated from the retired QUESTIONS.md (entry "📦 v0.2.0 is ready to publish", 2026-06-27)._

## Update 2026-06-30 (pass 44): credential ask re-routed to homelab

This had sat `blocked_on: user` for ~20 passes, but per fleet policy a **credential/API key is an
infra ask → homelab**, not the owner direct. Emailed `homelab@bot.yak.sh` (msg
`OLPifJlFq1sVMY15n5Epycqs7WBvoTceXMFe`) to mint the credential, offering two paths: (a) a
push-scoped RubyGems API key in env, or (b) **RubyGems Trusted Publishing (OIDC)** wired to
`craft-concept/cafe_car` so CI publishes keylessly on tag (preferred — no long-lived secret),
gated behind a GitHub Environment with owner approval. Flagged that the **owner go-ahead gate
stays owner-only** regardless. If the rubygems.org account is owner-held, homelab escalates.
`blocked_on` moved `user → homelab` to reflect the correct channel. Two gates remain: credential
(homelab) + owner go-ahead (owner).

- `version.rb` is already at **0.2.0**; **33 commits** have landed since the published `v0.1.2` —
  opt-in sessions/auth, the `cafe_car` macro rename, **CSV export**, **turnkey keyword search**,
  nested-attributes forms, the Pundit-verification footgun fix, and security hardening.
- CI green, `rake` green, demo healthy, docs + `CHANGELOG [Unreleased]` current.
- **On owner go-ahead + key in env:** finalize the CHANGELOG `[Unreleased] → [0.2.0]` with the
  date, tag `v0.2.0`, and `gem push`. Until then it sits release-ready on main.
- Apply the minimal-floor risk-check before pushing even on a verified owner go-ahead — a
  `gem push` is irreversible.

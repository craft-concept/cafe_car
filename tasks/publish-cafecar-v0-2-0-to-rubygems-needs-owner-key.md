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

## Update 2026-06-30 (pass 44, homelab reply): Trusted Publishing in flight

Homelab accepted the routing and chose **(b) Trusted Publishing (OIDC)** — keyless, owner-approval
structurally enforced. Mechanism now decided; in flight:

- **GitHub half (homelab, in flight):** PR adding `.github/workflows/release.yml` — triggers on a
  `vX.Y.Z` tag, publishes via OIDC (`rubygems/release-gem@v1`, no secret), runs in a **`release`
  GitHub Environment with the OWNER as a required reviewer**. So after a tag is pushed, the publish
  job *pauses* for the owner's explicit approval in the Actions UI — **gate #2 is now structural,
  not just convention.** *The PR is mine to review/merge* — that's the "wire/verify" step.
- **rubygems.org half (owner-gated, homelab escalating):** registering the trusted publisher
  (`cafe_car` → repo `craft-concept/cafe_car` → workflow `release.yml` → env `release`) must be
  done from the gem's rubygems.org account (owner `yaks`); an API key can't create it. Escalated
  to the owner along with the actual release go-ahead.
- **Note:** homelab found + cleared a stale local push key for cafe_car on the homelab box; flagged
  to the owner to rotate/delete on rubygems.org. Moot for OIDC (no stored key needed).

**Release path once both land:** push the `v0.2.0` tag → approve the gated job in the Actions UI.
`blocked_on` stays `homelab` until the PR lands (then I review/merge); then gated on the owner's
rubygems.org registration + go-ahead. Nothing for me to do until the PR arrives.

- `version.rb` is already at **0.2.0**; **33 commits** have landed since the published `v0.1.2` —
  opt-in sessions/auth, the `cafe_car` macro rename, **CSV export**, **turnkey keyword search**,
  nested-attributes forms, the Pundit-verification footgun fix, and security hardening.
- CI green, `rake` green, demo healthy, docs + `CHANGELOG [Unreleased]` current.
- **On owner go-ahead + key in env:** finalize the CHANGELOG `[Unreleased] → [0.2.0]` with the
  date, tag `v0.2.0`, and `gem push`. Until then it sits release-ready on main.
- Apply the minimal-floor risk-check before pushing even on a verified owner go-ahead — a
  `gem push` is irreversible.

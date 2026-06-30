---
id: publish-cafecar-v0-2-0-to-rubygems-needs-owner-key
title: Publish CafeCar v0.2.0 to RubyGems (needs owner key)
priority: P1
status: done
domain: Launch-blocking
created: '2026-06-30'
blocked_on: null
---

## Update 2026-06-30 (post-publish): SHIPPED — v0.2.0 live, checklist closed

cafe_car **0.2.0 is LIVE on RubyGems** via OIDC trusted-publishing — owner approved the gated
`release` job. Confirmed live (`created_at 2026-06-30T19:18:47Z`, 37 downloads at confirmation).
Post-publish checklist (pass 46) complete:

- **GitHub Release created** for the existing `v0.2.0` tag — body is the CHANGELOG `[0.2.0]`
  section, not pre-release, and now shows as **Latest** (`gh release list`):
  https://github.com/craft-concept/cafe_car/releases/tag/v0.2.0
- **README/docs version sweep:** no hardcoded stale version refs found. The Gem Version badge is
  dynamic (`shields.io/gem/v/cafe_car`); the install snippet is an unpinned `gem "cafe_car"`; no
  `~> 0.1` pins or `0.1.x` mentions anywhere in `README.md` or `docs/`. Nothing to change.
- **Gem resolves:** `gem list cafe_car --remote --exact` → `cafe_car (0.2.0)`.
- `bundle exec rake` green (rubocop + test + brakeman) before commit.

`status: done`.

## Update 2026-06-30 (pass 45): UNBLOCKED — owner did the rubygems.org side, shipping now

Both gates cleared, confirmed by **two VERIFIED internal mails** (holdco
`msg:1782846820644`, homelab `msg:1782846860830`):
  1. **Trusted publisher REGISTERED** on rubygems.org: `cafe_car` → repo
     `craft-concept/cafe_car` → workflow `release.yml` → environment `release`.
  2. **Stale cafe_car push key ROTATED/cleared** on rubygems.org (moot for OIDC anyway).
  3. **Owner go-ahead given** — the Actions-UI approval of the gated `release` job IS the
     final gate, and the owner is expecting it.

Executing the release sequence (pass 45):
  a. ✅ Finalized CHANGELOG `[Unreleased] → [0.2.0] - 2026-06-30`, fresh `[Unreleased]`
     skeleton + compare links. `bundle exec rake` green (rubocop clean / 122 runs 0 fail /
     brakeman 0 warn).
  b. Commit + push CHANGELOG → wait for CI green on main.
  c. Push the `v0.2.0` tag (guard enforces tag==version parity).
  d. **Owner approves the gated `release` job in the Actions UI** → OIDC publish.

Minimal-floor risk-check applied: pushing the tag is safe — it only *triggers* the job,
which structurally PAUSES on the `release` environment for the owner's approval before the
irreversible `gem push`. I never push the gem directly.

### Done in pass 45 — release queued, awaiting owner click

- Commit `6782ce2` (CHANGELOG finalize) pushed; **CI green** on it (verified HEAD ==
  origin/main == CI-green SHA).
- **Tag `v0.2.0` pushed** → Release workflow run **28469804814** triggered and is
  `waiting` (paused) on the `release` environment for the owner's review.
- Emailed the owner the direct approval link
  (`actions/runs/28469804814`); replied to holdco + homelab confirming the gated state.

**Only remaining step is the owner's approval of the `release` environment** — then OIDC
publishes 0.2.0. After it goes live: tag the GitHub release notes, refresh README badges/
version refs, verify `gem install cafe_car` pulls 0.2.0, then mark this task `done`.
`status: in_progress` until published.

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

## Update 2026-06-30 (pass 44, PR merged): GitHub half DONE → `blocked_on: homelab → user`

Reviewed + **merged PR #13** (`4d3c0fd`, "Add RubyGems trusted-publishing release workflow").
`.github/workflows/release.yml` is now on main. My review confirmed: `v*`-tag trigger gated by
`environment: release` (owner required reviewer, restricted to `v*`); minimal perms
(`id-token: write` for OIDC + `contents: write` for the GH release); a **version-guard** that
fails the job unless the stripped tag == `CafeCar::VERSION`; official `rubygems/release-gem@v1`;
`checkout@v5` matching `ci.yml`; MFA-required gemspec satisfied by OIDC. PR CI all green.

Homelab's GitHub half is complete; the rubygems.org half + go-ahead are **owner-only**, so
`blocked_on` moves `homelab → user`. **Remaining gates (both owner):**
  1. Register the trusted publisher on rubygems.org: `cafe_car` → repo `craft-concept/cafe_car`
     → workflow `release.yml` → environment `release`. (An API key can't create it.)
  2. Explicit release go-ahead (the Actions-UI approval of the gated job IS this go-ahead).

**My remaining steps, ONLY after the owner registers + signals go-ahead (do NOT initiate early —
pushing the tag before the trusted publisher exists would fail the OIDC exchange):**
  a. Finalize CHANGELOG `[Unreleased] → [0.2.0]` with the release date, commit.
  b. Push the `v0.2.0` tag (guard enforces version parity — tag exactly `v0.2.0`).
  c. Owner approves the gated `release` job in the Actions UI → publish.

- `version.rb` is already at **0.2.0**; **33 commits** have landed since the published `v0.1.2` —
  opt-in sessions/auth, the `cafe_car` macro rename, **CSV export**, **turnkey keyword search**,
  nested-attributes forms, the Pundit-verification footgun fix, and security hardening.
- CI green, `rake` green, demo healthy, docs + `CHANGELOG [Unreleased]` current.
- **On owner go-ahead + key in env:** finalize the CHANGELOG `[Unreleased] → [0.2.0]` with the
  date, tag `v0.2.0`, and `gem push`. Until then it sits release-ready on main.
- Apply the minimal-floor risk-check before pushing even on a verified owner go-ahead — a
  `gem push` is irreversible.

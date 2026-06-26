# CafeCar Worklog

Running narrative of each operating pass, newest first. Each entry: what shipped
(commit SHAs), what's in flight, decisions/assumptions, what's next.

---

## 2026-06-26 — Pass 1: CI rescue, backlog genesis, first hygiene wave

**Shipped (all on `main`, CI green):**
- **Fixed red CI** (`8970798`). Root cause was three-fold: `bin/brakeman` forced
  `--ensure-latest`, tying build pass/fail to brakeman's release cadence (8.0.5 shipped
  vs. locked 8.0.4 → exit 5); a stale `brakeman.ignore` fingerprint (generated under
  8.0.2) resurfaced the auto_resolver eval warning (exit 3); and the holdco onboarding
  commit left 65 rubocop offenses. Decoupled the gate, refreshed the fingerprint,
  autocorrected. `rake` fully green (0 offenses, 51 runs/0 failures, 0 warnings).
- **Built the backlog from zero** (`4f9c639`) — 12 triaged tasks translating the owner's
  directive into stability / OSS-hygiene / cnc / GTM / dogfood workstreams.
- **OSS community files** (`d05b2a2`, delegated to a builder) — CHANGELOG.md (Keep-a-
  Changelog), CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md, and gemspec
  `changelog_uri`. Expanded the README Contributing section to link them.
- **cnc investigation** (`78d902c`, delegated) — recommendation written to QUESTIONS.md.

**Decisions / assumptions:**
- `cnc` is **public**, not private (the AGENTS.md premise is stale) — it's the owner's own
  gem (4.5k downloads, MIT). So it is *not* an adoption blocker; the real issue is that
  it's a runtime dep dragging rubocop/thor/listen into production for two ~10-line
  monkeypatches. **Recommendation: inline those two methods + demote cnc to a dev
  dependency.** Surfaced to the owner in QUESTIONS.md; execution task
  (`cnc-inline-and-demote`) is **blocked on owner ratification**.
- Kept the CI brakeman gate decoupled from gem currency rather than chasing each release;
  dependency freshness belongs to bundle update / Dependabot, not the build gate.

**Flagged for the owner (QUESTIONS.md / blockers):**
- cnc dependency-strategy decision (see above).
- RubyGems publish key + version bump still owner-gated — no publish attempted.

**New follow-ups filed:** `deps-vulnerability-audit` (Dependabot: 56 vulns, 1 critical /
14 high — **P1**), `cnc-inline-and-demote` (P1, owner-blocked), `retro-tag-releases`
(no git tags exist; CHANGELOG links won't resolve until tagged), `triage-pr-11` (stale
Copilot draft PR from March).

**Next pass:** highest-leverage open item is `deps-vulnerability-audit` (security/trust)
or `feature-audit-v1-scope` (the owner's stability #1, gates the demo and dogfood). Also
quick wins: `ci-rubocop-check-gate` (drop the autocorrect-and-PR job; delete the stale
`rubocop/main` branch) and `readme-badges-accuracy`.

_Conductor · session: https://claude.ai/code/session_01MyoJrsYD55vDfHn5t4Fe5M_

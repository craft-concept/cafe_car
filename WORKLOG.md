# CafeCar Worklog

Running narrative of each operating pass, newest first. Each entry: what shipped
(commit SHAs), what's in flight, decisions/assumptions, what's next.

---

## 2026-06-26 — Pass 3: README honesty + CI gate cleanup

**Shipped (all on `main`, CI green):**
- **README accuracy + badges** (`7ab7903`, delegated) — fixed the false-advertising
  (`f.field(...).errors`→`.error`, `normalized_sort_key`→`normalize_sort_key`), corrected
  the install gem-list and Prerequisites to honest tested versions (Ruby 3.3+/Rails 8.0+),
  added CI/gem-version/license badges. Auth stack correctly left undocumented (experimental).
- **CI rubocop gate cleanup** (conductor, this commit) — the job ran `rubocop -Af github`
  and opened a "Rubocop Autocorrections on main" PR on every push (amateur-looking on a
  public repo, and it masked real lint failures). Switched to a check-only gate
  (`rubocop -f github`), removed the create-pull-request step, and deleted the stale
  `rubocop/main` branch.

**Sharpened diagnosis (for the auth fix):** the latent 500 is more entangled than "remove
the include" — `render_unauthorized` itself calls the Authentication concern and redirects
to `new_session_path`, a route the engine never defines. The direction-independent fix is
graceful 403 degradation when sessions aren't configured. Recorded in
`fix-halfbaked-features`.

**Next pass:** the auth graceful-403 fix (owner-independent bug fix, but I'll likely wait
for the sessions product direction before deciding how far to wire login); `retro-tag-releases`;
then `gemspec-release-polish` toward a credible (owner-gated) v0.1.x publish. Owner-gated:
cnc inline/demote, sessions direction.

---

## 2026-06-26 — Pass 2: security cleanup + honest v1 scope

**Shipped (all on `main`, CI green):**
- **Cleared every Dependabot alert** (`f02c924`, delegated) — 56 → **0** open, including
  the 1 critical (`rack-session`) and all 14 high (rack, puma, rails 8.1.2→8.1.3, nokogiri,
  etc.). Surgical `Gemfile.lock`-only bumps; `rake` stayed green; no gemspec changes.
- **Feature audit → `V1_SCOPE.md`** (`43b4aa7`, delegated) — every advertised feature
  classified **8 IN / 7 NEEDS-WORK / 2 OUT** with file-level evidence.

**Key findings / decisions:**
- **Auth/sessions is half-baked and carries a latent 500**: `Authentication` is
  force-included into every CRUD `Controller`, so a CRUD-only host with no sessions table
  can 500. The decouple is an unambiguous bug fix (queued in `fix-halfbaked-features`); the
  *product* call — ship experimental vs. finish vs. cut — is raised to the owner in
  QUESTIONS.md.
- **README false advertising** found (trust killers): `f.field(...).errors` → `.error`;
  `normalized_sort_key()` → `normalize_sort_key`; the `sessions` generator USAGE lies; the
  auth stack is undocumented; install gem-list is incomplete. Folded into the fix tasks.
- Builder hygiene held: both builders kept to disjoint files, cleaned generator artifacts,
  and left the committed tree green.

**Flagged for the owner (QUESTIONS.md):** sessions experimental-vs-finish-vs-cut decision
(new); cnc inline/demote (still pending).

**Next pass:** ship the README accuracy fixes (pure trust wins, in flight); then the
auth-decoupling bug fix; then `ci-rubocop-check-gate` + retro tags. The auth *product*
direction and cnc are the two owner-gated items.

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

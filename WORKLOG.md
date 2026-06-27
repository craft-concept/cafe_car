# CafeCar Worklog

Running narrative of each operating pass, newest first. Each entry: what shipped
(commit SHAs), what's in flight, decisions/assumptions, what's next.

---

## 2026-06-26 — Pass 8 (self-paced loop): v0.1.2 SHIPPED — release reconciliation + nested-attributes

**Owner published v0.1.2 to RubyGems** (uploaded 2026-06-27T01:00Z, built from `6b4f269`).
Roadmap milestones #1 (CHANGELOG) and #2 (publish v0.1.2) are **done**. The loop did not
freeze (per `6b4f269`); it reconciled the release and shipped the next feature.

**Release reconciliation** (the published 0.1.2 = current main, but the tag/CHANGELOG were
71 commits behind reality):
- Owner decisions: next dev version **0.2.0** (minor); **move the stale `v0.1.2` tag** to the
  shipped commit + cut GitHub releases.
- CHANGELOG honest 0.1.2 entry mined from the 71 shipped commits; `version.rb` → `0.2.0`;
  fresh empty `[Unreleased]` (`d583882`, `af1c1cb` lockfile sync; delegated). `rake` green.
- Moved `v0.1.2` tag → `6b4f269` (force, pushed). Cut GitHub releases for **v0.1.2** (Latest)
  and **v0.1.1** for a complete page.
- Housekeeping: `*.gem` build artifacts now gitignored, removed the stray `cafe_car-0.1.2.gem`
  (`b9f1ff5`).

**Nested-attributes form rendering** (`7896820`, delegated) — first-class `has_many` +
`accepts_nested_attributes_for` forms: `_nested_field.html.haml` (`fields_for` + `<template>`
for new rows), vanilla-JS add/remove with `_destroy` handling, `nested_attributes_type`
moved to front of `FieldInfo#type`. Tests **90 → 99**, `rake` + CI green. Regression guard
verified: `nested_attributes_type` returns `nil` unless `accepts_nested_attributes_for` is
configured, so belongs_to/plain-has_many rendering is unaffected. Closes
[[nested-attributes-forms]] (the reimplementation of closed PR #11, done right with tests).

**Filed:** [[bump-ci-actions-checkout-to-v5-node-20-deprecation]] (P2) — CI logs a Node 20
deprecation warning on `actions/checkout@v4` (not failing yet).

**Decisions/assumptions:** Builder subagent types `coder`/`designer` aren't registered in this
environment → used `general-purpose` for builds (same full abilities, scoped prompt). The
published 0.1.2 commit was identified as `6b4f269` (session-start HEAD with the owner's built
`.gem` sitting untracked).

**Next:** backlog is now P2 long-tail (generator-polish, docs-site/demo deploy — gate is
owner go-ahead + Railway cost, discoverability — sequence after demo). Loop continues.

---

## 2026-06-26 — Pass 7+ (self-paced loop): PR triage + generator tests

Running as a self-paced operating loop. Progress:
- **Closed stale draft PR #11** (nested has_many fields) with a courteous, specific
  explanation; filed [[nested-attributes-forms]] to reimplement it properly with tests
  (PR was untested + stale against a diverged main). Responsive-maintainer signal.
- **Generator test coverage** (`f6ae7ed`, delegated) — generator tests **3 → 21**, full
  suite **60 → 78**, `rake` + CI green. Covered install (Gemfile/routes/AppController
  injections), resource, controller, policy, notes.
- Surfaced 3 non-blocking generator issues → filed [[generator-polish]]: `resource`
  pollutes the engine repo when run from root; `notes` shells out instead of `inline: true`;
  `policy` double-namespaces. None are adopter-facing bugs.
- `fix-halfbaked-features` items 1–4 now done; only item 5 (tests for advertised
  turbo_stream/json/presenter/sort-paginate paths) remains — claimed next.

**Advertised-path tests** (`3c673a2`, delegated) — turbo_stream, json (confirms
non-displayable attrs don't leak), presenter render, sort/paginate. Suite **78 → 90**, no
broken paths found. `fix-halfbaked-features` done.

### Loop paused — gem is publish-ready

Autonomous, clearly-safe quality work is exhausted. State: CI green, 0 vulns, full OSS
hygiene + live Pages, honest v1 scope, cnc cut, rubocop-omakase, sessions optional+finished,
**90 tests** (generators + every advertised path). ~17 tasks done this session.

Remaining backlog is **owner-gated or low-value**, so the loop is paused (no point
idle-ticking on decisions only the owner can make):
- **Owner-gated:** `gem push` v0.1.x (RubyGems key); `docs-site-live-demo` (Railway deploy —
  cost/account + go-ahead); `dogfood-crayonbloom` (needs requirements); `potter`→cnc
  transitive; sessions homepage already resolved.
- **Owner-visible / discretionary:** `nested-attributes-forms` (a new feature — don't ship
  unprompted); `discoverability-launch` (sequence after publish + demo); `generator-polish`
  (P2 cosmetic; changing generator delegation isn't worth the regression risk unprompted).

Resumes on the owner's next message (answering a gate re-engages the highest-value work).

---

## 2026-06-26 — Pass 6: owner decisions — cut cnc, omakase, Pages

Owner ratified the pending decisions (cut cnc wholesale; rubocop→rails-omakase; sessions
optional AND finished; homepage→GitHub Pages). Reshaped the backlog accordingly.

**Shipped (on `main`, `rake` green):**
- **Cut cnc wholesale + rubocop→omakase** (`4387c07`, delegated) — inlined the two methods
  CafeCar used (`Hash#extract_if!`, `Module#define_class`) into `core_ext/`, removed the
  dep from gemspec + Gemfile + install generator, switched `.rubocop.yml` to inherit
  `rubocop-rails-omakase` (autocorrected 278 offenses across ~73 files, zero hand-fixes),
  and repointed `homepage` to GitHub Pages. cnc grep-clean; tests 51/0.
- **GitHub Pages landing page** (this commit) — `docs/` landing page + enabling Pages so
  the new homepage URL resolves (partial progress on [[docs-site-live-demo]]; the live
  clickable demo remains).

**Flag for owner:** cnc still resolves **transitively via `potter`** (potter → cnc) in
`Gemfile.lock` — out of CafeCar's own deps, but if you want cnc gone from the install tree
entirely, `potter` would need the same treatment.

**Sessions — optional AND finished** (`f4b1fda` Part A, `d91d2a1` Part B, delegated):
- **Optional / 500 fix:** `render_unauthorized` now `head :forbidden` when sessions aren't
  available (`CafeCar.sessions_available?` = login route exists AND sessions table exists,
  **fails closed** via rescue). CRUD-only hosts get a clean 403, not a 500. Reviewed the
  auth path directly — it fails closed, no access leak. Also fixed a latent i18n 500 in the
  login redirect.
- **Finished:** engine `resource :session` routes; configurable host user via
  `CafeCar.user_class_name` (default `"User"`); logout action; honest generator + USAGE;
  README "Sessions & Authentication" section. 9 new tests (51 → 60). `rake` + CI green.
- Conductor fixed a one-line stale code comment (`user_class` → `user_class_name`) and
  noted the supersession in `V1_SCOPE.md`.

**All four owner decisions are now shipped.** Homepage verified live (HTTP 200 at
craft-concept.github.io/cafe_car).

**Next:** remaining backlog — `triage-pr-11`, `docs-site-live-demo` (live demo beyond the
landing page), `discoverability-launch`, `dogfood-crayonbloom` (needs owner requirements).
Owner-gated: the `gem push` itself, and whether to chase cnc out of the `potter` transitive.

---

## 2026-06-26 — Pass 5: GitHub templates

**Shipped (on `main`, CI green):** issue forms (`bug_report.yml`, `feature_request.yml`),
issue-template `config.yml` (routes security reports to SECURITY.md, questions to the
README), and a `pull_request_template.md` with the `rake`-green / tests / CHANGELOG
checklist. Completes OSS-hygiene roadmap item #4. **10 tasks done.**

Remaining unblocked: auth graceful-403 fix, `triage-pr-11`. Owner-gated: cnc inline/demote,
sessions direction, homepage 404, the publish, CrayonBloom dogfood requirements.

---

## 2026-06-26 — Pass 4: release-prep polish

**Shipped (on `main`, CI green):**
- **Retroactive release tags** `v0.1.1` (`d73eb6f`) / `v0.1.2` (`256f822`) so the CHANGELOG
  compare/release links resolve. Tags only — not a publish.
- **gemspec release-polish** (`333754b`, delegated) — replaced the placeholder
  summary/description with a real value-prop pitch, added `required_ruby_version >= 3.3`,
  conservative `>=` floors on the direct deps (matching the lockfile), and
  `rubygems_mfa_required` + `bug_tracker_uri` metadata. `cnc`/`potter` left bare (pre-1.0).
  Completes roadmap item #2 **prep** — everything short of the owner-gated `gem push`.

**Flagged for the owner (QUESTIONS.md):** the gem `homepage` (`concept.love/cafe_car`)
404s — stand up the page or repoint to GitHub (left as-is, didn't guess at branding).

**State:** 9 tasks done. Remaining unblocked: auth graceful-403 fix, `github-templates`,
`triage-pr-11`. Owner-gated: cnc inline/demote, sessions direction, homepage, the actual
publish, CrayonBloom dogfood requirements.

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

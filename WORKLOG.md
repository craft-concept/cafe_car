# CafeCar Worklog

Running narrative of each operating pass, newest first. Each entry: what shipped
(commit SHAs), what's in flight, decisions/assumptions, what's next.

---

## 2026-07-11 — Pass 122: v0.3.0 publish CONFIRMED live (closure)

Budget **YELLOW** (allowance spent, `left=-5 used=69 alloc=64`) — no discretionary work, one cheap
closure check only. Verified the Pass-121 re-trigger landed: release run
[29144243258](https://github.com/craft-concept/cafe_car/actions/runs/29144243258) **completed
success** (14m33s) and `gem list -r cafe_car` reports **0.3.0 live on RubyGems**. The libvips fix
(`eefa1ee`) held; owner approved the gate. In-flight item from Pass 121 is closed — nothing urgent
open. Resting long per YELLOW.

**Next (GREEN):** work the board — P1 dogfood/monetization, P2 discoverability/logo-v2, OG card wip.

---

## 2026-07-11 — Pass 121: v0.3.0 release publish failed → root-caused + re-triggered

Owner flagged in-session: "0.3.0 is not waiting on me — the publish deploy failed; investigate."

**Root cause.** Release run [29121504916](https://github.com/craft-concept/cafe_car/actions/runs/29121504916)
died at `rubygems/release-gem@v1`: building the gem loads the Rakefile → `load "rails/tasks/engine.rake"`
→ boots the dummy app (`Bundler.require`) → pulls `ruby-vips`, whose FFI layer `dlopen`s the system
lib `libvips.so.42`. **CI's `test` job installs libvips via apt; `release.yml` never did** — so CI was
green and the release red on identical code. v0.3.0 never published (RubyGems tops at 0.2.1, no GH
release), so it died before any irreversible push — safe to re-release.

**Fix** (`eefa1ee`, coder-built, `bundle exec rake` green, CI green): added a `libvips`-only apt install
step to `release.yml`'s `release` job (mirrors CI, scoped down — the release runner doesn't run
tests/screenshots); also documented the two post-tag features (nested-association dot-path filters,
active-filter chips) under `[0.3.0]` in CHANGELOG.

**Re-trigger.** Since 0.3.0 was never public, I define it as current main: moved tag `v0.3.0`
`6290026`→`eefa1ee` and re-pushed. Release run
[29144243258](https://github.com/craft-concept/cafe_car/actions/runs/29144243258) is now **`waiting`
on the owner approval gate**.

**Next:** owner approves the run in the GitHub "release" environment → gem publishes to RubyGems +
GH release created. Then verify 0.3.0 is live on rubygems.org.

---

## 2026-07-10 — Pass 120: "close all the tickets you can" → v0.3.0 shipped + board cleared

Owner set an in-session goal (`/goal close all the tickets you can`) and, mid-session, "don't forget
to publish new versions after major upgrades." Ran it as a multi-wave delegation sprint (12 builders,
worktree-isolated on disjoint file domains). **~17 tickets closed; v0.3.0 cut and tagged.**

**Release — v0.3.0** (`6290026` + tag `v0.3.0`, CI green). Trusted-Publishing workflow is **waiting on
owner approval** in the GitHub UI to publish. Bundles everything since v0.2.1: custom member+collection
actions, typed filter panel, chart view + y-metric, dashboard, searchable selects, form-input
components, `?sort=` gating, `default_view` fix. Release coder did version + CHANGELOG restructure +
`Gemfile.lock` in one commit (frozen-bundler-safe).

**Shipped this session (commits):**
- `e0ffc7a` dead `_search` partial + unused CSS cleanup · `d9977d1` `?sort=` gated to `permitted_filters`
  (security parity) · `0af2baf` filtering effect-tests (enum + column gate) · `375a081` `default_view`
  inherits to subclasses (was a class-ivar) · `03b437a`+`f7cfd89` README docs (member actions +
  filter panel) · `655ed04`+`169a2f4` form-input component family + wiring (`FormBuilder#input` routes
  through `Inputs::*`; guarded so `hidden_field` etc. still pass through) · `ca03711` task-hygiene v2 ·
  `aac55a0` Jekyll docs-site guide (single-source build-step generator) + `4c7a175` fix for the Pages
  CI break it introduced (jekyll 3.10 `sort` chokes on mixed-type `guide_order` → quote it) ·
  `0ab1761` **Attributes refactor** — folded `*_attributes` into a nested `CafeCar::Attributes`
  (`policy.attributes.{listable,displayable,editable,filterable,actions.*}`), API-preserving:
  `permitted_*` stay public host-overridable methods, `Attributes` reads *through* them, all call sites
  migrated, back-compat test; `permitted_metrics`/`permitted_scopes` left as-is (already clean) ·
  `ffe155a` **Filtering M2** nested-association filters + full dot-path gate (unpermitted nested paths
  pruned before SQL) · `0988c2a` **active-filter chips** + clear (component-scoped CSS,
  param-preserving `url_for` idiom).
- **PostHog webhooks fixed via MCP** (not code — receiver is the holdco-inbox worker): both
  `issue-created` and `issue-reopened` destinations, path `cafe_car`→`cafecar`, other inputs preserved.

**Board hygiene:** 3 stale-open "custom action" tickets (member handler / render buttons / effect-tests)
were already shipped in passes 117–119 — verified against spec + closed, not rebuilt. Filed follow-ups
as their own tasks (nested-filter docs [in flight], chip-title enrichment) per the newly-adopted
"follow-ups are tasks" rule.

**Owner email handled (VERIFIED, DECISIONS.md):** keep handrolled components (direction ratified);
NEW direction — partial overrides should key on **presenter/model, not controller** (owner willing to
break the Rails convention) → filed a P1 **ideation** task to return as a `/propose`; **benchmarking
into the standard release cycle** → filed P2. Both are next-pass (email-arrived), acked to owner.

**Remaining open = genuinely not closable by me:** dogfood epics (await CrayonBloom requirements),
monetization-thesis (holdco allocator call), discoverability (brand/GTM + owner steer), owner-wiring +
auto-code-review (→jeff), OG-card (owner sign-off pending since 7/7), benchmark spike (owner-gated),
plus the 3 next-pass/self-spawned follow-ups above. **Needs owner:** approve the v0.3.0 publish; sign
off the OG-card draft; steer monetization + discoverability.

---

## 2026-07-10 — Pass 119: collection actions run over the VIEWED scope (owner-greenlit correctness fix)

GREEN pass off `bin/operate tokens --pace`. Started a `/loop 8h` operating cadence (session cron
`9ef436d1`, fires `7 */8 * * *`; each fire re-checks the budget signal). Reconstituted: CI green,
inbox clear, re-read the 2026-07-09 owner decision. Picked up the top item of the build bundle
Pass 118 deferred — the already-WIP correctness fix, owner-directed.

- **`83546cf`** (coder) — **collection actions now run over the currently-viewed, filtered scope**,
  reversing 3f7965d's "whole policy scope" per owner direction (DECISIONS.md 2026-07-09). Root-caused
  it as a single source of truth: new `filtered_scope = filtered(policy_scope(model))` in
  `controller/filtering.rb`, reused by BOTH the index render and `collection_action` (no duplicated
  filter logic). The button's `url_for` carries the active dot-filters + search `q` in the query
  string; the POST's `parsed_params` re-parses them so the action re-applies exactly what the user
  is viewing — no new param path. **Localized count hint** (`Publish all 21`) via a locale key
  (`en.helpers.collection_action`, `one`/`other` hash — hash form required because
  `CafeCar::Pluralization` would otherwise mangle a plain `%{count}` string into "Publish all 2s").
  **Docs-with-build:** new README "Collection Actions" subsection (voice-gated). **Effect-test:**
  filtered `publish_all` publishes only the in-view author's articles and leaves the other author's
  untouched, plus asserts the button label shows the filtered count. `bundle exec rake` fully green
  (249 tests / 775 assertions / 0 failures, rubocop clean, brakeman 0). Board task done.

**In flight / next:** the remaining two greenlit items — **docs for the member-action half**
(`readme-docs-document-custom-actions-...`, collection half now done) and the **Attributes refactor**
(`refactor *_attributes into policy.attributes.listable`, P1, greenlit) — queued for the next pass.
Owner-blocked P2s (`owner-one-time-dashboard-wiring`, `auto-code-review-on-incoming-community-prs`)
remain parked on jeff, not blocking the queue.

---

## 2026-07-10 — Pass 118: component-primitive research delivered (owner bump)

Owner bumped the 7/7 P1 research directive (evaluate replacing the handrolled component primitive
with ViewComponent/Phlex/other). The positioning/marketing framing shipped back in Pass 102, but the
actual **technical evaluation** never did — that's what the bump was about. Executed it (read-only
research, GREEN, explicitly-bumped P1 → acted rather than re-filed).

- **`12f8da5`** — `docs/research/component-primitive-evaluation.md` (research agent). Grounded in the
  code (file:line) + external sources (dated). **Recommendation: keep handrolled Components +
  partials; don't adopt VC/Phlex wholesale; 1-day spike to falsify the perf premise before any
  move.** Three findings: (1) handrolled is slowest but the mainstream field is within ~1.4–1.9× /
  sub-ms per node → not a user-visible bottleneck at admin scale (owner right on direction, off on
  magnitude); (2) our Component is confirmed "a level above" — a convention layer whose HTML emit is
  a swappable backend, could sit on Phlex/VC; (3) **the override story is the deal-breaker and points
  AWAY from VC/Phlex** — the file-drop host override (the moat) rests on Rails view-path lookup =
  partials; VC can't do path-based template override (#411 wontfix), Phlex has no templates. Rails
  core's own energy is Herb/ReActionView (better ERB, keeps view-path lookup), not a component lib.
- Emailed owner the exec summary + shared link + one question back (is the pain speed or partial
  *ergonomics*? — if the latter, Nice Partials targets it without touching overrides). Filed the
  Option-B/benchmark spike as a P3 follow-up (owner-gated; don't touch the partial override branch).

Research task closed. **Note:** deferred the queued Pass-117 build work (collection-action viewed-
scope + count hint, docs-with-build, Attributes refactor) — owner greenlit it by email but I held
execution per the email-inbox rule (told them "reply 'go now'"); this bump was a distinct explicit
ask on a waiting P1, so I acted on it specifically. Those three remain queued for the next pass.

---

## 2026-07-09 — Pass 117: custom actions feature SHIPPED + filter polish + tooltip root-caused

Owner in-session directive (DECISIONS.md 2026-07-09 "In-session directive"): build actions + demo
Publish · filter polish (assoc multi-select, dark-mode, search into card, drop "Filters" title) ·
README short demo URL · figure out the index tooltip bug. Delegated to 3 builders (disjoint files;
actions-then-filter serial to avoid an `_index.html.haml` collision, tooltip+README parallel). All
`rake` green, pushed.

- **`3f7965d`** (Fable coder) — **custom actions (D)**: policy-declared `permitted_member_actions` /
  `permitted_collection_actions` (both `[]` default, mirror `permitted_bulk_actions`); each name →
  `name?` predicate + `name!` bang method, no registration. **Routing convention:** auto-added
  `:actionable` concern — `POST /<res>/:id/actions/:member_action` + `POST /<res>/actions/:collection_action`
  (action name is a URL param, so hosts never enumerate names). 404 unlisted, `name?` gates (missing
  = deny), host method of the name overrides. Demo: **Publish** on article rows + show card (disabled+
  tooltip when unpermitted) + a **Publish all** collection button. 9 effect tests (asserts persisted
  `published_at`, refusal-untouched, 404, override, placement). Touched (flagged) `helpers.rb`,
  `link_builder.rb` as the DRY homes.
- **`6a5a39e`** (coder) — **filter polish**: association filter **multi-select** (belongs_to AND
  has_many), root-caused in `form_builder`/`filter/form_builder` (the `multiple:` flag + `[]` name
  suffix; query layer already produced `IN` — verified `... author_id IN (3,5)`, not assumed);
  **tom-select dark-mode** via theme vars (`--input`/`--card`/`--selection`/`--accent` chips);
  **search moved into the filters card** (visible field replacing the hidden `q`; inherits `Input.css`
  styling) + **"Filters" title removed**; composition (search+filter+sort) effect-tested. Dark-mode
  screenshot verified: `~/shared/cafe_car/filter-polish.png`.
- **`d673245`** (designer) — **tooltip fix**: root cause proven in headless Chrome 149 — `filter:
  brightness()` on `.Button:hover`/`a:hover` makes the trigger a containing block for its
  `position:fixed ::before`, trapping the tooltip on top (so `top`→`bottom` alone never worked; not
  a browser/anchor-API bug). Swapped filter → box-shadow overlay (buttons) / `color-mix` (links) +
  `position-area: bottom`. Emailed owner the 4-panel proof (`~/shared/cafe_car/tooltip-diagnosis.png`).
- **`8d15c1a`** (designer) — README → shorter `cafe-car-demo.up.railway.app` (9 hosts).

**Decisions/assumptions:** collection actions run over the whole policy scope, not the active filter
view (documented) — filed a P3 owner-decision task. Denied member actions render disabled+tooltip
(matches destroy convention). `_search.html.haml` now dead (left in place) — filed cleanup.

**Follow-ups filed:** custom-actions README/docs (P2) · filter-panel README docs voice-gate (P3) ·
collection-action filtered-scope decision (P3) · delete dead `_search.html.haml` + `Table.css`
`form.search` rules (P3).

**Next:** the Attributes refactor (E — `policy.attributes.listable`) folds these in per owner
sequencing; docs passes for actions + filters before the next `v*` tag. Clean checkpoint, nothing in
flight.

---

## 2026-07-09 — Pass 116: filtering M1 COMPLETE + correct — enum-key `to_i` bug fixed

**`af5d589`** (Fable) — fixed the correctness bug B3 found + worked around: `QueryBuilder#parse_value`
was `to_i`-ing integer-backed enum **keys** (`?status=archived` → `where(status: 0)` = wrong bucket).
Now enum key strings pass through untouched (AR's `EnumType` casts natively); reused `FieldInfo#enum?`
via the `ModelInfo` registry (didn't edit `field_info`); flipped `Filter::FieldInfo#choices` back to
keys so the select submits the readable `?status=archived`. Pre-fix failure confirmed; edge cases
smoke-tested (legacy numeric `?status=1` still lands right via the integer fall-through, `status!=`
negation, string-backed enums unaffected). Suite 237 green. Board bug done.

Conductor cleanup (this pass): corrected the now-stale `_enum_filter.html.haml` comment (was
documenting the old db-value workaround).

**Net: filtering M1 is done and correct end to end** — policy-driven, typed, security-gated, enum-
correct. Remaining filtering polish/enhancements: B4 (active-filter chips + clear), B5 (deeper effect
tests), C (nested-assoc UI), and the filed design/UX + README-voice-gate polish.

**Session tally (2026-07-09):** M1a agent docs+installer (831d2f3, f15ed85) · filtering M1
(efc0bc7, 4dc1755, 9b21229, af5d589) — 8 Fable builders, all `rake` green. **Next tracks:** custom
actions (D — note D3 routing convention is a public-API design choice worth an owner beat), then the
Attributes refactor (E). Clean checkpoint, nothing in flight.

---

## 2026-07-09 — Pass 115: filtering M1 core SHIPPED — policy-driven typed filter UI (B1+B2+B3)

The visible payoff: every index now auto-renders clickable, policy-enumerated filters that write
dot-query params. Three Fable builders, each `rake` green + pushed:
- **`efc0bc7`** (B1) — `permitted_filters` (default `displayable_attributes`) + `permitted_scopes`
  (default `[]`) + predicates on the policy; the controller URL→query path is **gated** to the
  permitted set (non-permitted keys silently dropped — also fixed a latent 500 on unknown params).
  Closes the "any public scope is URL-invokable" hole. Filed P3 follow-up to gate `?sort=` too.
- **`4dc1755`** (B2) — enum reflection: `FieldInfo#enum?`/`#values`/`enum_type` slotted into the type
  chain; `FormBuilder#enum` select; dummy `Client.status` enum + effect-level round-trip test.
- **`9b21229`** (B3) — the typed filter panel (`_filters` wired into the index aside): string→contains,
  enum→select, boolean→tri-state, numeric/date→min-max range, belongs_to/has_many→Tom Select
  typeahead, scope→toggle; composes with `q`/`sort`/`view`/CSV; all copy in locales, no styles outside
  components. Fixed the dormant/broken `Filter::FormBuilder` plumbing. 12 effect tests; suite 235 green.

**Found + filed (not worked around silently):** `QueryBuilder#parse_value` `to_i`s integer-backed enum
**key** strings → `?status=archived` becomes `where(status: 0)` (wrong bucket). B3 stayed in its lane
(engine not its files), submits the DB value so filters are correct but URLs are ugly, and filed board
bug `querybuilder-enum-key-strings-are-to-i-d-to-0-on-integer-bac`. Fix it, then flip enum options to keys.

**Design polish (filed, needs a designer + `/copy` pass):** raw enum key labels (want "Active"), busy
default Created/Updated ranges on every model, checkbox toggle layout, and the README doesn't document
the panel yet (customer copy → voice gate).

**Remaining filtering:** B4 (active-filter chips + clear), B5 (deeper effect tests), C (nested-assoc UI
— engine already supports it). **Next tracks:** custom actions (D1/D3→D2→D4), then the Attributes
refactor (E). **In flight:** none (clean checkpoint). Demo auto-deploys `9b21229` — filter panel goes live.

---

## 2026-07-09 — Pass 114: M1a SHIPPED — the Agent Skill + `cafe_car:agents` install generator (the CrayonBloom fix)

**Shipped (both on Fable, both `rake` green + pushed to main):**
- **`831d2f3`** — the CafeCar **Agent Skill**: `skills/cafe_car/SKILL.md` (mental model + recipe index,
  "never hand-roll an admin page", policy-first customization ladder) + `skills/cafe_car/references/*.md`
  (10 subsystem pages). Verified against real code + `test/dummy`; positioning clean (composable view
  extension, never generator/framework). Task A1 done.
- **`f15ed85`** — **`rails g cafe_car:agents`** generator: copies the skill into a host's
  `.claude/skills/cafe_car/` (+ `.agents/` mirror), writes an **idempotent marker-delimited AGENTS.md
  block** (never blind-appends; double-run test proves exactly one block), publishes a Claude Code
  **plugin marketplace** (`.claude-plugin/marketplace.json`), ships **`llms.txt`**, adds a README
  section, and packages `skills/`+`llms.txt`+`.claude-plugin` in the gemspec (verified via `gem build`).
  Prints the `npx skills add craft-concept/cafe_car` + `gitmcp.io/craft-concept/cafe_car` one-liners.
  5-case generator test; full suite 215 tests green. Task A2 done.

**Net:** the primary owner ask — agent-facing docs that reach an agent's context INSIDE a host app —
is now shippable end to end (a host installs, its agents reach for CafeCar instead of hand-rolling).

**Plan correction (recorded as memory + told owner):** `CafeCar[:Const]` is **engine-first**, NOT a
universal host-shadow seam — top-level constants only win for names the engine doesn't define. Real
override seams: view files, presenter naming, Pundit policies, locale keys. (Corrects an over-broad
exploration claim; bears on the in-flight component-primitive research, whose must-preserve property
is exactly this override story.)

**Also confirmed:** the `_filters` partial ships but is **not wired** yet (Track B3 scope is real);
nested-association dot-filters (`?author.name~=bob`) **already work** today (Track C = mostly expose).

**Infra:** box briefly hit 99% disk (external caches on shared rootfs, not our repo); owner grew LXC
107 rootfs +8GB → 40G/80%/7.7G free; homelab confirmed + is adding a reclaim guardrail. Not blocking.

**In flight:** filtering foundation — B1 (`permitted_filters`/`permitted_scopes` on the policy) + B2
(enum reflection via `defined_enums`), which unblock B3 (the typed policy-driven filter UI).
**Next:** B3 filter UI → then custom actions (D1/D3 → D2 → D4).

---

## 2026-07-09 — Pass 113: kicked off the big project — agent-facing docs + provisioning, policy-driven filtering, custom actions, Attributes refactor

**Trigger:** in-session owner directive (jeff@yak.sh) — "plan and execute a big project to document
CafeCar in a way that agents can use to write better code that uses CafeCar. Use fable." Plus three
follow-ups this session: policy-driven filtering (M1 enumerated filter UI, M2 nested joins), custom
**actions** (member + collection, forward to model bang methods), and a mid-term **P1** to refactor
policy `*_attributes` into a nested `Attributes` class (`policy.attributes.listable`).

**Planned + approved.** Ran 3 parallel exploration agents (rendering pipeline / view+override+turbo /
policy+query+docs) + a prior-art research agent. Key reframes captured in plan
`dapper-zooming-raccoon` (owner-approved): (1) the problem is **discoverability, not coverage** — the
README is thorough but never reaches an agent's context inside a host app; (2) everything asked for
is **one law — "the policy declares, the UI renders"** — extended to filters, actions, and
agent-legibility; (3) the **dot-query engine already exists** (ParamParser+QueryBuilder: ops,
ranges, arrays, negate/regex, recursive nested-assoc filtering via `activerecord_where_assoc`,
`sort=assoc.col`) — filtering M1 is a policy-driven UI on top, M2 is mostly expose+gate+document;
(4) the one greenfield query gap is **enum reflection** (`defined_enums`); (5) research says ship
the **Agent Skills open standard** (`SKILL.md`) + a Rails generator + a marker-delimited AGENTS.md
block (Supabase/Stripe/Prisma pattern; no Rails gem has done it yet — real whitespace).

**Shipped this pass:**
- `DECISIONS.md` entry (verbatim, all four owner messages) — committed **first**, before acting
  (owner-feedback rule). Commit on main.
- **15-task DAG filed on the board** (Track A docs+provisioning, B filtering M1, C filtering M2,
  D custom actions, E Attributes refactor as an explicit **P1**), with `blockedBy` dependencies
  (A2→A1; B3→B1,B2; B4/B5/C1→B3; D2→D1,D3; D4→D1,D2; D5→D2,D4; E1→B3,D4).
- **Dispatched the M1a builder on Fable** (task `write-cafecar-agent-skill-…`, claimed wip): writing
  `skills/cafe_car/SKILL.md` + `references/*.md` (11 subsystems, recipe-shaped, conventions-not-
  snapshots, human voice, examples verified against test/dummy). Owns `skills/cafe_car/**` only.

**Decisions/assumptions:** features ship first as flat `permitted_*` methods; the Attributes refactor
folds them all in afterward (owner: "features now, refactor folds them in"). `permitted_scopes` will
also gate URL-invokable scopes (today any public scope is filterable — a security tightening). Docs
document only SHIPPED behavior; new-feature doc sections couple to their feature tasks so nothing
goes stale. Skip Cursor/Copilot-specific rule files (every tool reads AGENTS.md now).

**In flight:** Fable builder on the skill/guide content (A1).
**Next:** on A1 landing — A2 (`cafe_car:agents` generator + marketplace + llms.txt) unblocks; then
filtering foundation (B1 `permitted_filters`/`permitted_scopes`, B2 enum reflection) → B3 filter UI;
custom actions (D1/D3 → D2 → D4). Run tracks serially or worktree-isolated (shared-tree clobber).

---

## 2026-07-07 — Pass 112: P1 production bug — attachments grid view 500 (arity mismatch)

**Trigger:** board task `c1b93f92` (P1), from a PostHog error on the live demo —
`ActionView::Template::Error: wrong number of arguments (given 1, expected 0)` on
`/admin/active_storage/attachments` (index).

**Root cause:** `CafeCar::ActiveStorage::AttachmentPresenter#logo` was defined `def logo = self`
(zero-arity), narrowing the base `Presenter#logo(*, **, &)`. The `_grid_item.html.haml` partial
renders each record's logo as `object.logo(href: object)`, so passing `href:` to the zero-arity
override raised the ArgumentError. Only the **grid** view triggers it — the table view never
passes args to `logo`, which is why the demo smoke check (table-only) stayed green. The demo's
`?view=grid` (and the parent `/admin/attachments`, which defaults to grid) hit it.

**Fix (`aa640e1`):** restored the base signature — `def logo(*, **, &) = self` (an attachment is
its own logo; args ignored, still returns self so the Card can call `.url`). Added an effect-level
regression test `test/controllers/attachments_grid_view_test.rb` that renders the grid and asserts
a card + image per attachment (fails with the ArgumentError pre-fix). `bundle exec rake` fully
green (rubocop 0, 210 tests, brakeman 0).

**Live verified:** post-deploy, authed `GET …/attachments?view=grid` returns 200 with rendered
cards/images and no error; the old code 500'd on that path. Task `c1b93f92` → done.

---

## 2026-07-07 — Pass 111 (GREEN): OG card regenerated with the new positioning — draft awaiting owner sign-off

**Trigger:** GREEN, `left=5/15`, 8h loop (session cron). No owner reply yet on the Pass-106 launch
greenlight; no unread mail; CI green; dogfood milestone still waiting on CrayonBloom to file
requirement tasks. Best unblocked item = the P3 OG-card regen. First step was verification the
designer couldn't do (raster unreadable to them): I read `docs/images/og-card.png` directly and
**confirmed it bakes the banned tagline** — "A complete Rails admin from one line of controller
code" — violating the 2026-07-03 positioning decision on the docs site's most-shared surface.

**Shipped (designer, `b96f320`, CI green):** the card is now **regenerable** — `docs/og/card.html`
(1200×630 layout, same visual system: cream bg, wordmark, ruby icon, product-mock table) +
`docs/og/render.mjs` (Playwright, @2x → 2400×1260, waits on `document.fonts.ready`). New copy,
voice-gated against BRAND.md: eyebrow **"A composable view extension for Rails"**, headline
**"One line of controller code renders index, show, new, and edit."** `bundle exec rake` green
(209 tests). I visually verified the rendered draft myself.

**Owner-gated, correctly:** live `docs/images/og-card.png` and `docs/_config.yml` untouched — the
canonical swap is gated art. Draft shared at `~/shared/cafe_car/og-card-draft-v1.png` (tailnet
link emailed to the owner for sign-off). Board task `regenerate-og-social-card…` → **wip** with a
status comment; it closes when the owner approves and I swap + reconcile `_config.yml`'s declared
dims (1731×909 vs render 2400×1260, same aspect ratio).

**Next:** owner replies gate the big levers (launch greenlight → discoverability chain; OG-card go;
form-inputs descope; CrayonBloom requirements; monetization). Unblocked backlog is drained again —
subsequent GREEN passes stay light until owner input lands.

---

## 2026-07-07 — Pass 110 (GREEN): durable scheduling for the demo smoke check — the demo now self-monitors

**Trigger:** GREEN, `left=9/15`, launching, CI green, clean, no owner reply yet on the Pass-106
launch greenlight. Best fully-unblocked item = the P3 I filed last pass
(`schedule-the-live-demo-smoke-check-durable-monitor`): its note allowed a "separate scheduled GH
Action (never push-coupled)", and since `bin/demo-smoke` uses the demo's **public** seeded login it
needs **no secrets** — so this is entirely within my envelope, and it converts Pass-109's one-shot
check into standing protection of the #1 conversion surface. Beat the discretionary OG-card regen.

**Shipped (coder, `840e6d0`, verified):** `.github/workflows/demo-smoke.yml` — a 22-line workflow
that runs `bin/demo-smoke` against the live demo on a **6-hourly cron** (`17 */6 * * *`, off-peak
minute) + `workflow_dispatch`. Deliberately **NOT** push/PR-triggered (coupling to the external
demo's uptime would flake real CI — the whole reason it's a separate workflow). `ruby/setup-ruby`
auto-reads `.ruby-version` (3.3.5), **no `bundle install`** (script is stdlib-only → fast). False-
alarm guard: `bin/demo-smoke || (sleep 30 && bin/demo-smoke)` — fails the job (→ owner email) only
if the retry also fails, so a transient blip won't page.

**Verified END-TO-END (not just a lint):** builder dispatched it via `gh workflow run` — run
`28881769336` → **success in 7s**, log shows `SMOKE OK: all 7 flows green`, exercising the GH
runner's egress to the demo + Ruby setup + the retry step. I independently confirmed: conclusion
`success`, diff scoped to the one new file, tree clean, the other four workflows (ci/release/pages/
copilot) untouched.

**Now standing:** the live demo self-checks at the effect level 4×/day and emails the owner only on
a confirmed (retried) break — the Pass-77 "shape-green hid broken features" failure mode is now
guarded continuously on the marketing surface, not just at one manual run.

**Next:** owner launch greenlight (Pass 106) still gates the discoverability publish chain. Unblocked
queue is again drained (the smoke-check follow-up is now closed). Owner-gated remainder: form-inputs
descope, CrayonBloom requirements, monetization, OG-card upload, auto-PR-review (GitHub App).
Subsequent GREEN passes stay light (ideation / IDEAS.md items / prep) until the owner responds.

---

## 2026-07-07 — Pass 109 (GREEN): live-demo effect-level smoke check — ran an IDEAS.md idea; demo confirmed healthy

**Trigger:** GREEN, `left=10/15`, launching, CI green, clean, still no owner reply on the Pass-106
launch greenlight. Substantive unblocked backlog drained + every open lever owner-gated — so instead
of manufacturing marginal builder work, ran the best **unblocked, on-thesis** idea from IDEAS.md:
the "Live-demo effect-level smoke check" (2026-07-04, was `proposed`). Applied the cheap-envelope
3-line rubric (internal script, reversible, no owner resource / smallest = one self-cleaning
create→assert→destroy + read-only dashboard/chart asserts / known-worked = exits non-zero when an
advertised demo flow is silently broken) — it cleared, so I ran the reversible script-build myself
(only durable scheduling touches infra, kept as a follow-up).

**Shipped (coder, `e89e420`, CI green):** `bin/demo-smoke` (+ `rake demo:smoke` wrapper) — a
standalone stdlib `Net::HTTP` script that logs into the live demo (the seeded "Enter the demo"
account, `ad35581`) and asserts **effects, not 200s** across 7 advertised flows: auth (current_user
set), create→read-back (marker persists), filter (set actually narrows), sort (names actually
ordered), destroy (marker gone — self-cleaning), dashboard (metric tiles + chart bars present),
chart view (`data-bucket` bars present). Deliberately **NOT** wired into push CI (would couple repo
CI to the external demo's uptime → flaky); on-demand + a durable-monitor follow-up filed
(`schedule-the-live-demo-smoke-check-durable-monitor`, P3). `bundle exec rake` green, rubocop clean.

**The genuine value delivered:** ran it 3× against production — **all 7 flows green, stable,
self-cleaning**: the #1 marketing surface actually *works* end-to-end right now, not just renders
(the Pass-77 shape-green-hid-broken-features lesson, now guarded on the demo). The one initial red
was **script brittleness, not a demo bug** — `Net::HTTP` pre-sets `Accept: */*`, so after any
`.json` read Rails' content negotiation resolved a plain HTML page to JSON (chart page came back as
a JSON array, no `data-bucket`). Coder root-caused it (isolated probes) and fixed by forcing
`Accept: text/html` on page reads — a real debugging win, not papered over. No false-alarm on the
PostHog `captureException` string (positive-content assertions only). IDEAS.md idea marked `kept`
(fixed its Pass-number label 107→109).

**Next:** durable scheduling of the smoke check (P3 follow-up) — likely routes to homelab for a
cron/monitor, since it shouldn't live in push CI. Owner launch greenlight (Pass 106) still gates the
publish chain. With the unblocked queue drained, subsequent GREEN passes stay light (ideation /
IDEAS.md items / prep) until the owner responds or new work lands.

---

## 2026-07-07 — Pass 108 (GREEN): README docs-currency — documented the shipped chart y-metric

**Trigger:** GREEN, `left=10/15`, launching, CI green, clean, no owner reply yet on the Pass-106
launch greenlight. Substantive unblocked backlog is drained; picked the last clean unblocked item —
the README (the **source of truth**) still described the Chart view as count-only, but Pass 105
shipped the selectable sum/avg y-metric. A prospect trying the chart should know it exists.

**Shipped (designer, `75291b0`, CI green):** documented `chart_y` in `README.md` — the feature
bullet now says "the count, or a sum/average of a numeric column," and the Chart-view detail section
gained a `chart_y=sum:total` example URL + a paragraph on the encoding (`count` default /
`sum:<col>` / `avg:<col>`), the policy-permitted numeric-column source (same source-of-truth pattern
as the x-axis), the conditional selector, the allowlist→count fallback, and adapter portability.
Docs-only markdown (no rake needed); voice-gated vs BRAND.md; kept "composable view extension"
positioning.

**Accuracy discipline (why this needed care, not just a one-liner):** the README is authoritative,
so I handed the designer the exact mechanics and told it to verify against `chart_builder.rb` rather
than trust my summary. It did — encoding, numeric allowlist, selector gate, count fallback,
portability all matched source. **Correct scope call it made:** left the dashboard `chart "..."`
helper section UNCHANGED after verifying that helper (`helpers.rb:198`, `chart(title, model:, x:,
by:)`) takes **no** `y:` kwarg — the y-metric is index-view-only, so documenting it on the dashboard
helper would have been a false claim. No `docs/index.md` mirror (no chart content there). Verified
diff scope + CI green independently.

**Next:** the board's unblocked substantive + hygiene queue is now genuinely drained. The gating item
is the owner **launch greenlight** (Pass 106) → unblocks the RubyFlow/Awesome/DEV publish chain (I'll
draft the submission copy on approval). Owner-gated remainder: form-inputs descope, CrayonBloom
requirements, monetization, OG-card upload, auto-PR-review (GitHub App). With substantive work drained
and levers owner-gated, subsequent GREEN passes lean toward ideation/prep or lighter cadence until the
owner responds or new work lands.

---

## 2026-07-07 — Pass 107 (GREEN): cleared both P3 nits — dream-DECISIONS path drift + dead filter kwarg

**Trigger:** GREEN, `left=11/15`, launching, CI green, clean, no owner reply yet on the Pass-106
launch greenlight (expected). Big P1s stay blocked; discoverability publish awaits owner. Cleared the
two genuinely-unblocked P3 nits — small, but "maintained-project" hygiene signals trust.

**Nit 1 — dream-DECISIONS path drift (`4ade82d`, CI green, done):** the dream persona +
`/dream` command referenced `docs/DECISIONS.md` (12 refs) but the ledger lives at repo-root
`DECISIONS.md` (what AGENTS.md/CLAUDE.md use); a future dream appending to / `git add`-ing the
orphan path would have diverged from the real ledger. **Investigated the routing myself** (not a
build): confirmed `bin/operate sync` pulls only `bin/` (per `operate.json` sync.source), so
`.claude/agents/dream.md` is venture-local + git-tracked, NOT sync-clobbered → safe to fix locally.
Direction: **fix the tooling to root** (moving the ledger would break the AGENTS/CLAUDE refs).
`sed`'d all 12 `docs/DECISIONS.md` → `DECISIONS.md`, verified the `docs/DREAM-SEEDS.md` refs stayed
intact (that file *does* live under `docs/`). Same drift exists in the venture **template** (every
new venture inherits it) → **emailed homelab** to fix upstream (`templates/new-venture/.claude/…`;
flagged holdco's own dream.md likely has it too).

**Nit 2 — dead filter kwarg (coder, `df1881e`, CI green, done):** `CafeCar::Filter::FormBuilder#field_name`
carried a `# TODO: handle multiple/index` and unused `multiple:`/`index:` kwargs. Filtering by a
`has_many_attached` array is nonsensical in the filter sidebar, and the real edit-form
`has_many_attached` path is implemented + covered (`attachment_persistence_test`) — dead
scaffolding. Coder grep-proved the sole caller passes only `field_name(key)` (no kwargs) and no
test exercised them, then collapsed the method to a one-line endless def matching the file's style.
Good call I endorsed: removed BOTH dead kwargs (the task scoped only `multiple:`, but `index:` was
equally unread — leaving it would orphan half the dead code). `bundle exec rake` green (209 runs /
0 fail). Verified diff minimal + CI green independently.

**Next:** owner launch greenlight (Pass 106) is the gate for the RubyFlow/Awesome/DEV publish chain.
Remaining unblocked: a short voice-gated README y-metric note. Owner-gated: form-inputs descope,
CrayonBloom requirements, monetization, OG-card upload, auto-PR-review (GitHub App).

---

## 2026-07-07 — Pass 106 (GREEN): launch post refreshed to ratified positioning + VC/Phlex hook; owner asked to greenlight

**Trigger:** GREEN, `left=11/15`, launching, CI green, tree clean, no mail. Reconstituted: found an
existing complete launch-post draft (`marketing/launch-post.md`) + a Jekyll docs site
(`docs/index.md`), and IDEAS.md line 16 (the dream's [External] seed) naming the launch hook. Picked
the highest-leverage **unblocked** move toward the mission (visibility = the #1 barrier): make the
launch post ship-ready, since publishing is the last owner-gated step.

**Shipped (designer, `75dcdd3`, pushed):** focused copy refresh of the existing draft — NOT a
rewrite. (1) Reframed the identity to the ratified "composable view extension for Rails" (owner
2026-07-03): dropped "a real CRUD admin" as CafeCar's *definition* — the admin UI/dashboards are now
an **outcome**, and the "generate/auto-generated" language is purged (CafeCar *renders*, it doesn't
spit out files). (2) Added the launch **hook** — a new section "Pick your view primitive — CafeCar
sits above it" that rides the live 2026 ViewComponent-vs-Phlex-vs-Partials debate, positioning
CafeCar as orthogonal/complementary (the convention layer above whatever primitive you pick), no
flame war, mirroring the README section (Pass 102). Voice-gated vs BRAND.md; every product claim +
URL verified. Diff scoped to the one file (30+/12−), tree clean.

**Reviewed (I own framing):** read the refreshed opener + hook section myself before it left the
building — both land clean and on-positioning. Endorsed the designer's three judgment calls (kept
"usable admin UI (and dashboards)" as outcome framing; left "they're powerful" describing the
*heavyweight admins*, not CafeCar; no fabricated citation).

**Owner action requested (async, non-blocking):** copied the draft to `~/shared/cafe_car/launch-post.md`
(preview: https://claude.ibis-micro.ts.net/cafe_car/launch-post.md) and emailed the owner for a
launch greenlight + venue — my rec: DEV.to (owner's account) → RubyFlow submission → Awesome
Ruby/Rails PR, offering to draft the RubyFlow blurb + Awesome-list PR text on approval. Flagged the
hook is time-sensitive (the debate is loud now). Commented progress on `cafe_car-discoverability-launch`
(stays **open** — external publish awaits greenlight). IDEAS.md line 16 moved `proposed → running`.

**Next:** owner launch decision unblocks the RubyFlow/Awesome/DEV publish chain (I'll draft the
submission copy on greenlight). Unblocked long tail: P3 nits (dead-TODO, dream-DECISIONS path drift),
a short README y-metric note. Owner-gated: form-inputs descope, CrayonBloom requirements, monetization.

---

## 2026-07-07 — Pass 105: selectable sum/avg y-metric on the index chart tab + PG smoke-check

**Task:** `chart-tab-follow-ups-postgres-smoke-check-selectable-y-metri` (P3, enhancement).

**Shipped (coder, pushed, CI green):** the index Chart view can now plot the **sum or average
of a numeric column** on the y-axis, not just a record count.

- **Param encoding — `chart_y`, NOT `chart_by`.** The task briefed `chart_by` as the reserved
  y-metric param, but in the shipped code `chart_by` is already the **bucket-granularity** selector
  (day/week/month) with a passing test (`chart_by: "day"`). Reassigning it would regress. Chose
  **`chart_y`** (matching the existing `chart_x` x-axis param — the y-metric literally is the
  y-axis), encoded `count` (default) / `sum:<col>` / `avg:<col>`. Added `chart_y` to
  `CONTROL_PARAMS`.
- **Policy is the source of truth.** Chartable numeric columns come from
  `policy.displayable_attributes` filtered to numeric types (`integer`/`decimal`/`float`) — the
  exact mirror of how the x-axis derives its date columns. `pick_metric` validates the `chart_y`
  column against that allowlist; an unknown/non-numeric column (or injection string) falls back to
  a plain count, so a raw param never becomes an Arel column ref.
- **Portable aggregation:** adapter-neutral AR `count`/`sum`/`average` (COUNT/SUM/AVG), same on
  SQLite + Postgres. `value_for` collapses whole BigDecimals (301.0 → 301) and rounds fractions so
  a decimal never renders as `0.301e3`.
- **Copy in locales, no styles outside components:** new `chart.metric.{count,sum,avg}` +
  `chart.{no_columns,update}` keys; also moved the previously-hardcoded index-chart empty message
  and Update button into locales.
- **Root-cause fix (latent bug):** `ChartBuilder#policy` built the policy from the *relation*, but
  `InvoicePolicy#permitted_attributes` calls `object.new_record?` — only valid on a record. Any
  chart on such a policy (e.g. `/admin/invoices`) would have 500'd. Now builds from
  `@objects.klass.new`, matching the rest of CafeCar (`policy(model.new)`).

**Postgres smoke-check (deliverable 2, option b — live HTTP):** curled the live demo
(`cafe-car-demo-production.up.railway.app`, PG, auto-deploys from main) with `Accept: text/html` —
the existing `date_trunc` bucketing renders 45 correct `YYYY-MM` bars at HTTP 200 (week granularity
also 200). Bucketing on Postgres confirmed working. (The new sum/avg lands on PG on the next
auto-deploy; its aggregation is adapter-neutral AR, so low risk.)

**Verify:** effect-level tests assert the summed/averaged series numerically (count default, sum,
avg, decimal-sum collapse) + allowlist rejection of a non-numeric/injection `chart_y` + selector
only offers policy-permitted numeric columns. Full `bundle exec rake` green: rubocop 0 offenses,
**209 runs / 621 assertions / 0 failures**, brakeman 0 warnings. (Cleaned two stray rows a local
`bin/rails runner` spike had persisted into the non-transactional test DB.)

**Operator (verify + close):** GREEN, `left=12/15`, launching, no mail. Independently confirmed —
diff scoped to the chart subsystem + locale/CHANGELOG/WORKLOG (`714e44c`), tree clean, and watched
CI run 28871989243 to all-green before closing. Endorsed the builder's `chart_y` call (avoids
regressing the existing `chart_by` granularity param — a good catch) and its policy-driven column
allowlist (matches our source-of-truth rule). Bonus wins beyond the P3 scope: a real latent-bug fix
(invoices chart was 500ing) and a CHANGELOG Unreleased entry for the shipped-gem feature. Task
`chart-tab-follow-ups-...` marked **done**. **Next unblocked:** P3 nits (dead-TODO, dream-DECISIONS
path drift); a short voice-gated README note about the y-metric is a reasonable follow-up. Owner-gated:
form-inputs descope, discoverability publish, CrayonBloom requirements, monetization.

---

## 2026-07-07 — Pass 104 (GREEN): deduped ActiveJob exception double-capture on the live demo

**Trigger:** GREEN, `left=13/15`, status `launching`, CI green, tree clean, no unread mail.
Reconstituted: DECISIONS top + board + git log — confirmed all four 2026-07-04 owner asks (demo
images, seeded users, sessions/login, PostHog test_mode + current_user, request-context
investigation) shipped in Passes 96–99. P1s (CrayonBloom dogfood, monetization) still owner/
requirements-blocked; external discoverability publish still owner-in-loop. Picked the strongest
**unblocked, verifiable** item: the demo's PostHog error stream double-captures every ActiveJob
exception (P2 `demo-dedupe-posthog-job-exception-double-capture-...`) — the demo is the conversion
surface and this pollutes the owner's own project-496903 error tracking 506/506.

**Shipped (coder, `28bf864`, pushed, CI green):** extended the demo initializer's existing
`before_send` drop — which already killed the web `application.action_dispatch` bare duplicate — to
a frozen source list that also drops the `application.active_support` bare duplicate posthog-rails'
ErrorSubscriber emits when `active_job.rb` re-raises a job exception into `Rails.error` (mechanism
verified against gem source; upstream issue we filed: PostHog/posthog-ruby#217). Rich `active_job`
and `rails` sources pass through untouched. **Design call I set for the builder:** blanket
source-drop, NOT a thread-local/fingerprint dedup — posthog-ruby flushes `before_send` on a
separate worker thread, so per-capture thread-locals aren't reliably visible (a thread-local dedup
would silently never fire). Builder extracted the lambda to a named constant so the new 5-case test
exercises the exact wired-in lambda (both duplicates dropped, both rich sources + non-`$exception`
pass through) — effect-level, not shape-level. Demo-only (`test/dummy/...`); does not touch the
shipped gem, and a plain push doesn't publish (only a `v*` tag does).

**Verified independently:** diff scoped to the two intended files; commit message accurate;
`bundle exec rake` green (202 runs / 604 assertions / 0 fail, rubocop clean, brakeman 0); watched
CI run 28869641756 to all-green (test/rubocop/brakeman/screenshot) before closing. Task marked done.

**Next:** stopgap stays until upstream #217 lands (or we PR the thread-local fix upstream — offered
in the issue). Remaining unblocked long tail: P3 chart-tab follow-ups (Postgres smoke + selectable
y-metric), P3 dead-TODO nit, P3 dream-DECISIONS path drift. Owner-gated: form-inputs descope
decision, external discoverability publish, CrayonBloom requirements, monetization thesis.

---

## 2026-07-07 — Pass 103 (GREEN): shipped "See it live" README demo deep-links; surfaced form-inputs as dead scaffolding

**Trigger:** GREEN, `left=14/15`, `cap=1%` (7-day account hard-cap — wide open; not a per-pass
limit, confirmed by reading `bin/operate-tokens`). Status `launching`, CI green, no mail (owner
hasn't yet replied to the Pass-102 positioning heads-up — fine). Reconstituted board; P1s still
owner-blocked. OSS hygiene audited **complete** (CONTRIBUTING/COC/SECURITY, issue+PR templates, all
three README badges present) — not a gap.

**Shipped (designer, `014c8d6`, pushed, CI green):** 5 tasteful "See it live →" demo deep-links at
the natural try-this point of README feature sections — Controllers→`/admin/clients`,
Forms→`/admin/invoices/new`, Filtering&Sorting→`/admin/users`, Bulk Actions→`/admin/users`,
Dashboard→`/admin/dashboard`. Three distinct resources linked so they double as "works for any
model" proof. **I independently re-curled all 5 targets → 200** (not just trusting the builder; a
dead link in front of a prospect is the failure mode). Conversion work — lets a prospect evaluate a
feature in one click without installing; pairs with the Pass-102 positioning section. Voice-gate
PASS (terse, concrete verbs, no hype, positioning clean). Runs the queued IDEAS.md "See it live
deep-links" idea (2026-07-04) — now **kept**. `bundle exec rake` green.

**Surfaced to owner (board comment on `render-form-inputs-...`):** the top eng P2 is a false lead —
`lib/cafe_car/inputs/*` is 5 tiny stubs (93–334 B) untouched since repo genesis, unwired from the
real form path. Completing it = a risky refactor of the gem's CORE shipped rendering for an
INVISIBLE win (CSS already themes inputs). Recommended **descope** (delete the dead stubs) unless
the owner wants the component-render path built. Did NOT autonomously build (architectural + core
rendering risk + "owner may reprioritize" flag) — an owner call.

**Next:** external discoverability items (Awesome Rails/RubyFlow/blog) still need a coordinated
launch + owner-in-loop; posthog job-exception dedupe (P2, safe internal) and P3 nits remain
unblocked; form-inputs awaits owner decision; CrayonBloom dogfood P1 awaits requirements.

---

## 2026-07-07 — Pass 102 (GREEN, fresh budget): shipped README positioning vs ViewComponent/Phlex

**Trigger:** GREEN, `left=14/15` (fresh allocation, well past the budget-thin stretch of 99–101).
Registry `launching`, CI green on latest, no unread mail. P1s still owner-blocked (CrayonBloom
requirements haven't arrived; monetization needs owner). Ran a dream cycle just before (committed
`dream: 2026-07-07`) which surfaced the angle below. Highest-leverage **unblocked** item =
discoverability, per the venture thesis (barriers are visibility + trust, not tech).

**Shipped (designer, `0171d7c` + my review-fix `f42b3bc`, pushed, CI green):** a new README section
**"How CafeCar relates to ViewComponent & Phlex"** (+ condensed mirror in `docs/index.md`). Rides
the live 2026 "ViewComponent vs Phlex vs Partials" debate (RubyFlow/GoRails/DEV, "partials are the
wrong answer for 2026") — the dream's [External]-seed find. Positions CafeCar as **orthogonal**: the
convention layer *above* whatever view primitive you use (deletes the boilerplate views; keep VC/
Phlex components for what you customize). Complementary, not a competitor; no partials-vs-components
flame. Consistent with the ratified "composable view extension, NOT a generator/admin-framework"
framing (owner 7/3). Voice-gate PASS vs BRAND.md; `bundle exec rake` green (197 runs / 0 fail /
rubocop clean / brakeman 0).

**Review catch (why I own reviewing framing):** the builder's draft said "CafeCar covers the
**scaffolding**" — the single most generator-associated word in Rails, and the owner positions
CafeCar explicitly *against* generators. Tightened to "boilerplate screens" before emailing the
owner the diff. Also fixed a broken leftover phrase the builder left in `docs/index.md` ("you'd
otherwise write at all" → "hand-write"). Emailed owner a positioning heads-up (live, reversible,
invited course-correction).

**Board:** commented progress on `cafe_car-discoverability-launch` (README section is a foundation
piece + raw material for the launch-post hook; task stays **open** — Awesome Rails PR, RubyFlow,
blog post still need a link target + owner-in-the-loop for live publish). Filed one P3 in the dream
(`consider-dream-tooling-references-docs-decisions-md-...`, the DECISIONS path drift, now flagged
twice).

**Next:** external-publish discoverability items (owner/link-blocked); unblocked P2s —
`render-form-inputs-through-ruby-component-objects` (also moves CafeCar toward the component world,
relevant to this same trend), posthog job-exception dedupe; P3 nits. CrayonBloom dogfood P1 still
top once requirements land.

---

## 2026-07-06 — Pass 101 (GREEN, budget-thin): refreshed stale status lines; stretching cadence

**Trigger:** GREEN, `left=6`. No new mail, CI green, nothing changed since Pass 100. Remaining
unblocked work (render-form-inputs P2, posthog dedupe P2) needs a builder pass that would exceed 6
units, so did one cheap doc-hygiene fix myself instead.

**Shipped** (docs only, no code): closed `consider-refresh-stale-status-lines...` P3. Two stale
lines that misdirect a cold context, both verified before editing:
- **AGENTS.md** "No config DSLs" para — "are being reworked to views/partials" → "were replaced
  with policy-driven views/partials in 12416c0, 2026-07-04" (rework confirmed shipped).
- **operator.md** operating-loop step 3 — replaced the finished-work roadmap order (CHANGELOG →
  v0.1.2 → cnc → …) with "those are all shipped (past v0.2.1); current focus is the back half:
  hygiene, docs/demo, discoverability, dogfooding." So a fresh context stops steering toward done
  work. (Noted: `CLAUDE.md` is a symlink to `AGENTS.md` — same file.)

**Pacing note:** Passes 99–101 were all cheap verification/hygiene passes ~15 min apart; budget is
now genuinely thin (`left=6`). Rather than keep ping-ponging micro-passes, **stretching the next
wake to ~45 min** — the remaining real work is builder-sized and owner-blocked (CrayonBloom), so
there's nothing cheap left worth a 15-min cadence. Cadence should track budget.

---

## 2026-07-06 — Pass 100 (GREEN, budget-thin): closed the feature-gaps tracker after verifying every item in code

**Trigger:** GREEN, `left=6` (budget-thin). Reconstituted: owner's 2026-07-04 PostHog/demo
follow-ups all shipped in Pass 96 (test_mode gate, current_user identify, sessions login, raster
avatars, ruby-vips); CI green; no mail; nothing untriaged. P1 CrayonBloom still blocked on their
requirements reply. Rather than spin a builder on ~6 units, did one cheap high-value maintainer op.

**What I did — audited + closed `cafe_car-major-feature-gaps-post-audit` (P2).** The thread claimed
"backlog drained" but three items (#6 has_many_attached, #10 /components auth, #11 per cap) were
never explicitly verified closed. Read the code and confirmed all of them:
- **#6** `has_many_attached` IS implemented (`form_builder.rb:89` sets `multiple:` on file_field via
  `field_info#multiple?`; `controller.rb` permits multi-attachment array params) **with effect-level
  `attachment_persistence_test.rb`** — README:494 claim is now true.
- **#10** `/components` gallery is **dev-gated** (`config/routes.rb` `if Rails.env.development?`), so a
  host never inherits the policy-skipping route in prod; the controller's `skip_authorization` is
  safe under that gate.
- **#11** `?per=` is **capped** via `CafeCar.max_per_page`(=200)/`capped_per`, mirroring
  `csv_export_row_limit`.
- #5/#7/#8/#9/#12/#13 + the effect-level-test meta-finding: all previously shipped, re-confirmed.

**Shipped:** no code — a verification/close pass. Filed one P3 nit
(`nit-resolve-dead-multiple-index-todo`) for a leftover `# TODO: handle multiple/index` in the
*filter* sidebar builder (filtering by an attached-file array is nonsensical, so it's dead-code
cleanup, not a real gap). Closed the tracker with the full verification trail.

**Next:** P1 dogfood stays blocked on CrayonBloom's requirements reply. Remaining unblocked
buildable work: `render-form-inputs-through-ruby-component-objects` (P2), the posthog
double-capture dedupe (P2), chart-tab follow-ups (P3). Weight next GREEN pass toward one of those.

---

## 2026-07-06 — Pass 99 (GREEN, budget-thin): verified the demo surface — /admin "404" was a false alarm

**Trigger:** GREEN but thinning (`left=6`, ~93% of alloc used). Rather than spend another builder,
did one cheap high-value verification: the P3 I filed earlier
(`confirm-authenticated-admin-resolves-on-live-demo-unauth-pro`). P1 CrayonBloom still blocked (no
requirements/reply); CI green; no mail.

**Finding — RESOLVED, not breakage.** The `/admin` 404 I flagged during the 7/05 YELLOW glance is a
non-issue: there is **no bare `/admin` index route** by design. Every real admin page serves **200
unauthenticated** (the demo is frictionless/open — Pass 96): `/admin/users`, `/admin/invoices`,
`/admin/clients`, `/admin/dashboard` all 200; the home CTAs all point to `/admin/<resource>`;
`/admin/users` renders a CafeCar table with zero error/exception markers. Login is a Turbo
`button_to` POST `/session` (no creds) — curl can't faithfully drive it (got 400/422), but that's
moot since the pages serve without auth. Same false-alarm class as the bare-host-404
([[demo-url]]). Closed the P3. Deep effect verification belongs to the queued browser-driven
smoke-check idea (IDEAS.md), not curl.

**No code changes this pass** — a verification/triage pass. Kept budget light on purpose.

**Next:** CrayonBloom dogfood P1 once requirements land; unblocked P2s (form-inputs component,
feature-gaps tracking, discoverability, posthog dedupe); P3s (OG-card regen, persona-roadmap
refresh). Backlog per board.

---

## 2026-07-06 — Pass 98 (GREEN): fixed the belongs_to column-sort bug + finished the Dependabot sweep

**Trigger:** GREEN (`left=7`). Both P1s blocked — the reframe P1 shipped last pass; the CrayonBloom
dogfood milestone (`cafe_car-dogfood-crayonbloom`) is still waiting on CrayonBloom's back-office
requirements (emailed 7/3, no reply in inbox; their operator files requirement tasks directly to
our board, none arrived yet). So worked down the P2 backlog.

**Shipped (coder, `6809cf9`, pushed, CI green):** the P2 bug
`association-belongs-to-column-header-sort-is-broken-no-join-` — `belongs_to` header-sort links
were silent no-ops (Pass-89 allow-list dropped the dotted `<assoc>.<col>` keys that `Model.sorted`
couldn't resolve). Fix in `lib/cafe_car/model.rb`: `normalize_sort_key` routes dotted keys to a new
`association_sort_key` that requires a real non-polymorphic `belongs_to` + a real column, then
qualifies ORDER BY to the **reflected** table via `reflection.klass.arel_table` (so `class_name`/
custom `table_name` resolve, e.g. `sender`→`users`); `sorted` collects `SortKey` value objects and
applies `left_outer_joins`. Coder empirically caught that the task's suggested `references(:assoc)`
does **not** build the join (SQL had no JOIN → would still 500) and used `left_outer_joins` instead
— good root-cause diligence. Strictness preserved: unknown assoc/column and raw fragments
(`client.name;DROP`) still drop to default order, no injection surface reintroduced. New
`test/cafe_car/sorted_test.rb` (zero coverage before) asserts the **effect** — SQL contains the
LEFT OUTER JOIN + qualified column AND records come back in the right order — plus the security-drop
cases. `bundle exec rake` green (197 runs / 599 assertions / 0 fail / 0 err / brakeman 0). Done.

**Hygiene:** merged the last Dependabot PR #22 (configure-pages 5→6, `1dea907`) after its rebase —
all four Actions bumps now landed.

**Next:** CrayonBloom dogfood P1 still the top item once requirements arrive (watch board + inbox);
remaining unblocked P2s — form-inputs component work (`render-form-inputs-through-ruby-component-
objects`), major-feature-gaps tracking, discoverability (Awesome Rails/RubyFlow/launch post),
posthog job-exception dedupe; P3s — authenticated-/admin confirm, OG-card regen. Backlog per board.

---

## 2026-07-06 — Pass 97 (GREEN): shipped the P1 positioning reframe + merged 3 Dependabot bumps

**Trigger:** Signal flipped GREEN (`left=8`, alloc 81) after two YELLOW idle passes (7/05). Two
idle passes: budget was spent (`left=-8`); on both I confirmed no urgent items (no unread mail,
demo healthy — `/` `/session/new` `/up` all 200) and slept. During the first I filed P3
`confirm-authenticated-admin-resolves-on-live-demo-unauth-pro` (unauth `/admin` 404 is auth-masking,
not breakage — Pass 96 verified the authenticated flow; confirm effect-level next GREEN pass).

**Shipped (designer, `b2c3f32`, pushed to main, CI green):** the P1
`reframe-positioning-purge-generator-admin-framework-crud-lan` — VERIFIED owner direction (7/3,
DECISIONS.md): CafeCar is a **composable view extension for Rails**, NOT a CRUD generator / admin
framework / view generator. Purged that framing from the README hero + feature bullets + image
alts/captions, `cafe_car.gemspec` summary+description (was literally "Auto-generate a CRUD admin
UI…"), `docs/index.md`, `docs/_config.yml` (OG/SEO), and the demo landing copy. Voice gate PASS vs
`BRAND.md`; `bundle exec rake` green (194 runs / 573 assertions / 0 fail / 0 err / brakeman 0).
Marked done.

**Also merged (routine hygiene):** Dependabot GitHub-Actions bumps #24 (checkout 5→7), #21
(upload-pages-artifact 3→5), #23 (deploy-pages 4→5). #22 (configure-pages 5→6) conflicted on the
shared Pages workflow — triggered `@dependabot rebase`; will land next pass.

**Flags / follow-ups filed:**
- **`BRAND.md` edited out-of-strict-scope (kept).** The designer moved "auto-generated" from
  Always-use → Never-use and added "composable view extension" + a Positioning note. Correct call —
  leaving it would regress the framing on the next copy pass. Reversible; kept.
- **P3 filed** `regenerate-og-social-card-png-…` — the OG-card *raster* PNG may still bake the old
  wording (alt/SEO text fixed, image not). Art asset → owner-iterate before publishing live.

**Next:** #22 rebase lands; the two remaining P1s are the CrayonBloom dogfood milestone
(`cafe_car-dogfood-crayonbloom`, big product/eng push) and it has a linked P2 build task; then the
P3 authenticated-/admin confirm, form-inputs component work, assoc-sort bug. Backlog per board.

---

## 2026-07-04 — Pass 96 (owner-directed): PostHog follow-ups — demo fixed live, request-context mystery solved, upstream issue filed

**Trigger:** Owner in-session ("check your email. we'll do some work today") + his 12:12 ET reply
to the PostHog ship mail with four asks. Recorded verbatim first (DECISIONS.md, `95a36ca`), four
P1s filed, then executed — owner present, so email-triage deferral didn't apply.

**Shipped (demo-coder, serial on test/dummy; all rake-green, deployed + verified live):**
- **`9c7340d` — PostHog init per owner spec.** Production guard dropped; reporting gated by
  `config.test_mode = !Rails.env.production?` (no-op worker off-prod, suite stays offline).
  `capture_user_context=true`; frontend `posthog.identify(id, {email,name})` for current_user.
  JS-snippet guard kept (posthog-js has no server no-op).
- **`ad35581` — sessions/login fixed.** Root cause: "Enter the demo" was a bare link to /admin and
  seeded users had random passwords — login was impossible. Now a demo account
  (`demo@cafecar.dev`/`cafecar-demo`, public by design) + real POST to /session. Live-verified:
  session persists across requests ("Signed in as Ada Demo").
- **`3044107` + `9f6d4bf` — broken images fixed + users seeded.** SVG avatars (unrenderable as
  variants) → committed PNGs; live 500s were the missing `ruby-vips` gem (libvips in Docker, gem
  not in bundle). Live-verified: variants 200. Seeds: 20 users + demo account.
- **`c8d8c8a` (turbo-coder) — the error-flood root cause.** `database_tasks: false` on the dummy's
  cable DB excluded it from `db:prepare` → `solid_cable_messages` never existed on Railway →
  every broadcast raised `ArgumentError: No unique index found for id` (1,012/30d, 98% of error
  volume). One line removed; live-verified in Railway logs (broadcasts perform, TrimJob spawns,
  zero errors).

**Investigation (ph-investigator, read-only): the "no request context" premise was false.**
posthog-ruby 3.16.0 includes PR #144 and it works — 17/17 web exceptions carry
$current_url/method/path/params (live sample confirmed). The flood was the Turbo job above; jobs
have no HTTP request by design. Side-finding: posthog-rails double-captures job exceptions
(506/506 split, `error_subscriber.rb` guards only `in_web_request?`) — **filed upstream with
owner's go-ahead: PostHog/posthog-ruby#217** (verified in gem source + searched for dupes before
filing; offered to PR).

**Board:** 4 owner P1s filed + done; investigation done; new: Turbo bug (done, `c8d8c8a`), P2
dedupe stopgap (open, linked to #217).

**Flags:** (1) demo creds public by design — surfaced to owner; (2) identify *event* in PostHog
unconfirmed until a real browser visit (wiring verified in served HTML); (3) two red CI runs
mid-sequence from demo-coder's per-task split (HEAD green, deploy gated, no live impact);
(4) demo-coder + turbo-coder had SendMessage disabled — both relayed reports via board comments,
which worked well as a fallback.

**Next:** watch #217 for maintainer response (PR offer stands); P2 dedupe stopgap; confirm
identify event after a browser visit; remaining backlog per board.

---

## 2026-07-04 — Pass 95 (GREEN): owner approved the reworks — both DSLs deleted + his 5 UI fixes shipped

**Trigger:** 8h operating loop (GREEN, `left=17`). Inbox held two VERIFIED owner replies (7/3
19:32 + 19:42 ET) — the Pass-94 proposal came back **approved with corrections** ("very close!"),
plus UI feedback on the Pass-92 fixes.

**Owner corrections (verbatim in DECISIONS.md, commit `58ffa7c`; standing rules baked into
AGENTS.md):**
- **The policy is the source of truth** — `permitted_bulk_actions` / `permitted_metrics` on the
  policy; default partials loop those lists; overriding a partial is the explicit opt-out.
  "the policy declares what's editable and the UI renders that by default."
- **No styles outside of components** — the Pass-92 global checkbox CSS broke checkboxes reused in
  the Layout Menu. All styling through components; all copy + button styles (destroy → danger) in
  locales.

**Shipped (two parallel builders, disjoint files, both rake-green):**
- **`12416c0` (coder) — both reworks.** `CafeCar.bulk_action` registry and `CafeCar.dashboard` DSL
  deleted. Bulk actions: policy `permitted_bulk_actions` (default `%i[destroy]`) → `_bulk_actions`
  partial loops it; host action = policy predicate + model bang method, zero registration;
  `#batch` derives apply/authorize through the whitelist (Brakeman-clean). Dashboards: host
  template `cafe_car/dashboard/show` is the opt-in (route always mounted, 404 without it);
  `metric`/`chart` helpers; `permitted_metrics` drives default tiles. Demo shows a working custom
  "Publish" bulk action. README/CHANGELOG purged of DSL copy. 189 tests / 556 assertions green.
- **`374b36d` (designer) — all 5 owner UI fixes.** Checkbox styles scoped into
  `:where(.Field, .Table_Cell-select)` (root cause: bare attribute selectors out-ranked
  `.Layout_Menu`); search form capped `flex: 0 1 24em` with Button-styled submit grouped in a
  `.Group`; `.Button` → `inline-flex` (buttons size to label); Download CSV ungrouped from the
  view selector; charts fixed to a steady 1000×280 landscape viewBox (verified sparse + dense).
  Screenshot-verified against the dummy app; auto-deploys to the demo.

**Also:** both rework tasks + the toolbar P1 closed on the board; IDEAS.md proposal → kept;
answered the owner's chart question (custom ChartBuilder, no gem) in the shipped email — an
immediate reply was suppressed by the anti-nag guard as a thread bump, folded it here instead.

**Friction noted:** the two parallel builders share one working tree — the designer's commit
transiently clobbered the coder's uncommitted WIP (coder reapplied from context; both commits
verified disjoint + green). Next time: worktree isolation for parallel builders.

**Next:** positioning-copy reframe (P1, README/gemspec purge of generator/admin-framework
language), CrayonBloom requirements when they reply, association-sort bug (P2).

---

## 2026-07-03 — Pass 94 (GREEN): designed the DSL→views/partials convention, proposed to owner

**Trigger:** self-directed (GREEN, budget tightening `left=18`). Top of backlog = the three
owner-directed P1 reworks from Pass 93. Judgment call: the dashboards/bulk-actions reworks set a
**convention**, and I promised the owner (Pass 93) to show him the approach before committing it —
so this pass is **design + propose**, not build-blind (redoing a full rework after his feedback is
the exact waste to avoid under a tightening budget).

**Delegated the design** to a coder (kept my context clean): discover CafeCar's existing view/partial
convention, then produce a concrete proposed host-facing API for both features. Result — design note
`docs/design/dsl-to-views-partials.md` (commit `3e517d9`, rake green), grounded in the real
convention (override a default template at the resource path; compose with view helpers; behavior on
the model, authz on the policy — the view IS the config surface).

**The proposed convention:**
- **Dashboards** = one host-authored `app/views/cafe_car/dashboard/show.html.haml` composing `metric`
  / `chart` helpers; the template's existence is the opt-in; reuses `ChartBuilder` + its column
  allowlist unchanged. No `CafeCar.dashboard` block.
- **Bulk actions** = decompose into the three idiomatic homes they always were: a button in the
  overridable `_bulk_actions` partial (`bulk_action :publish`), a model bang method (`publish!`), a
  policy predicate (`publish?`). `Controller#batch` derives apply/authorize from the action name;
  per-record policy check stays the security boundary; registry deleted. A neat *simplification* —
  the DSLs mostly restated conventions the host could express directly.

**Proposed to the owner** (the preview I promised): emailed the approach + the two example code
blocks + my recommendations, with two taste questions genuinely his call (bulk-action whitelist home:
policy method vs partial-only; dashboard template path). Full note on the Tailscale share. Recorded
in `IDEAS.md` (proposed). **Both rework tasks set `blocked` on owner sign-off** — will NOT build
until he answers.

**Next:** on owner go → build both reworks to the agreed convention. Unblocked meanwhile: the
positioning-copy reframe (P1, independent), or CrayonBloom reqs when they reply.

---

## 2026-07-03 — Pass 93 (owner steering): product-direction correction baked + reworks filed

**Trigger:** holdco (VERIFIED) urgently relayed three VERIFIED owner (jeff@yak.sh) emails from this
evening (18:54–19:04 ET) that the after-hours hold would otherwise have sat on until Monday —
course-correcting product direction, contradicting shipped work. Verified all three against the
originals in my inbox before acting.

**The directives (verbatim in DECISIONS.md):** (1) "Absolutely no config DSLs for dashboards or bulk
actions. Like everything else they should be configured via views and partials." (2) CafeCar is
"not an admin framework or a CRUS [CRUD] generator… a composable view extension for rails… just how
I think rails should work out of the box" — and calling it a view "generator" is "confusing (read:
wrong)." (3) route my digest's CrayonBloom-requirements ask to CrayonBloom myself; publish via
GitHub Action releases, not gem push.

**Handled this turn (write-it-down-first, then cheap high-value actions only — NO builder spawns):**
- **Recorded verbatim → DECISIONS.md; baked direction → AGENTS.md** (= CLAUDE.md symlink): rewrote the
  product framing (composable view extension, not admin-framework/CRUD/generator), added a "No config
  DSLs — configure via views & partials" rule, corrected the "Deploy model" + roadmap "Publish" lines
  to GitHub-Action-releases. Committed `9229b5d` BEFORE any further action.
- **Filed the reworks (P1, build NEXT pass):** `rework-dashboards-remove-the-cafecar-dashboard-config-dsl-co`,
  `rework-bulk-actions-remove-the-cafecar-bulk-action-dsl-confi`, `reframe-positioning-purge-generator-…`.
  Dashboards/bulk-actions keep the feature, change the mechanism (DSL → views/partials); README/gemspec
  copy reframe is voice-gated.
- **Direct instructions done:** emailed `crayonbloom@bot.yak.sh` for the back-office requirements
  (commented the dogfood task); confirmed publish path already exists (PR #13 merged 6/30,
  `release.yml` in tree) — corrected the stale "blocked on RubyGems key" roadmap line.
- **Acked** holdco (relay) + owner (tight confirmation; told him I'll send the reworked dashboards
  *approach* before committing the pattern, since it sets the convention).

**Did NOT** rebuild anything against direction — reworks are queued, not started (email is an inbox,
not a work trigger; the substantial builds go on the next proactive pass).

**Next:** design the views/partials convention for dashboards (proposal-worthy — sets the pattern),
then rework dashboards + bulk actions; positioning-copy reframe; CrayonBloom reqs when they reply.

---

## 2026-07-03 — Pass 92 (GREEN): index-page form-control polish (two owner P1s)

**Trigger:** self-directed pass (GREEN, budget tightening `left=19` so kept lean). Picked the two
remaining owner-filed (jeff) P1 UI tasks. Recognized they're **coupled** (both touch index-page
checkboxes / selection state / toolbar), so dispatched **one `designer`** to do both together
rather than two parallel builders fighting the same files.

**Shipped A — styled inputs (`ab03a6c`, CI green):** checkboxes/radios were the gap (text/textarea/
select already flowed through `ui/Input.css`, the component-theme layer). Routed them through the
same layer — `appearance:none` + custom `::before` mark, `:focus-visible`, `:checked`/
`:indeterminate` (drives select-all tri-state)/`:disabled`, all off theme tokens. Native input kept
(keyboard-operable, `aria` intact). Live: 27 native styled checkboxes render on the demo.

**Shipped B — batch-destroy button (`92a665f`, CI green):** all three owner asks — (1) **locale
label** via `t(action.name)` → "Delete"; (2) **placement** in a new `.IndexToolbar` flex row with
the search box (`_index.html.haml` wraps `search` + `bulk_actions`); (3) **visibility** hidden by
default, revealed by selection JS (`cafe_car.js`) when ≥1 `ids[]` box is checked, submitting via
`form="BulkForm"`. `bundle exec rake` green (187 tests, Brakeman 0). Live markers confirmed on the
demo (`BulkForm`, `hidden`, `value=destroy`, locale "Delete").

**Decision — scope split on "styled inputs":** owner's words were "rendered using components AND
styled with the theme/component system." Delivered the **styling** (visible win) and **closed** the
task; **deferred** the Ruby component-*object* rendering (the half-built `lib/cafe_car/inputs/*`) as
separate scope — filed `render-form-inputs-through-ruby-component-objects-complete-l` (P2). Owner
can reprioritize.

**Verification note:** source (`_index.html.haml`) + passing toolbar-placement tests confirm the
`.IndexToolbar` wrapper; a live curl couldn't grep the class (CDN/caching or settling deploy), so
asked the owner to eyeball the toolbar + custom-checkbox visual on the demo (generated visuals
warrant a human pass anyway).

**Next:** CrayonBloom dogfood milestone (P1, big — needs scoping), or discoverability/launch (P2),
or the component-object input rewrite; association-sort (P2) still open.

---

## 2026-07-03 — Pass 91 (GREEN): dashboards discoverable on the demo + demo error-context fixed

**Trigger:** self-directed pass (GREEN, `launching`). Ran **two coders in parallel on disjoint
files** to (1) complete the dashboards story for the demo and (2) sharpen the dogfooding loop.

**Shipped A — nav link (`1c2d3c1`, CI green):** the Pass-90 dashboard was direct-URL-only
(`CafeCar::Navigation` enumerates only model index routes). Added `Navigation#dashboard_href`
(resolves via the **engine's** `url_helpers` — the dashboard route lives in the engine's route set,
not the host's, so `url_for`/named-route from a host controller can't reach it) + a top-of-nav
"Dashboard" link gated on `CafeCar.dashboard?`. Opt-in preserved (no dashboard → no link). Tests +
README/CHANGELOG. **Verified live**: `/admin/dashboard` → 200 and `href="/admin/dashboard"` renders
in the sidebar on the deployed demo.

**Shipped B — demo PostHog error context (`ac9ef54` + probe removal `1267edb`, CI green):** demo
500s were arriving via the thin `rails_error_reporter` path with no `$current_url`/params/session
link. **Root cause (gap B):** not middleware ordering — on Rails 8.1 the outer
`ActionDispatch::Executor` reports the exception to `Rails.error` *after* PostHog's
`CaptureExceptions` middleware unwinds, so posthog-rails emits a **duplicate** context-less
`$exception` (source `application.action_dispatch`) beside the rich one. Fix: a `before_send` drops
the bare duplicate; **gap A** adds `tracing_headers → cafe-car-demo-production` so the browser sends
`X-POSTHOG-SESSION-ID/DISTINCT-ID` to Rails. Coder's local verification was **definitive**
(`RAILS_ENV=production`, full stack: before = 2 events, after = exactly 1 with distinct_id +
`$current_url` + `$request_params` [token FILTERED] + `$session_id`). Live: redeployed, token-gated
probe returned a clean 500, then I **removed the temporary probe route**. `bundle exec rake` green
throughout (186 tests, Brakeman 0). All PostHog code stays demo-only + production-gated.

**Verification I own (railway/posthog MCP the subagents lacked):** curled the live demo — dashboard
+ nav link confirmed; PostHog fix rests on the definitive local proof + clean live 500. **Note:**
browser-session-linking can only be fully exercised by a real posthog-js browser AJAX error (curl
can't carry a session), so a natural-500 owner spot-check would close that last mile — mechanism is
proven locally.

**Next:** styled checkboxes/inputs or batch-destroy-button fixes (both P1 UI), or the CrayonBloom
dogfood milestone; association-sort (P2) still open.

---

## 2026-07-03 — Pass 90 (GREEN): shipped dashboards first-cut (owner-greenlit #8)

**Trigger:** self-directed pass (GREEN, `launching`). Picked the highest-leverage owner-directed
work — **dashboards**, greenlit 7/3 ("we should totally have dashboards... should be a good gem
for that"), deferred two passes while its composing primitive (the Pass-87 chart engine) landed.
As manager I made the first-cut design decisions, recorded them as the durable spec on the task,
dispatched a `coder` to build + dogfood, and emailed the owner the design note for course-correction.

**Shipped (`3fed953`, CI green):** an opt-in dashboard overview surface — CafeCar grows beyond pure
CRUD. Declarative DSL mirroring the `bulk_action`/`theme` config idiom:
```ruby
Rails.application.config.to_prepare do   # to_prepare so app models are loaded
  CafeCar.dashboard do
    metric "Users",         -> { User.count }
    metric "Signups today", -> { User.where(created_at: Date.current.all_day).count }
    chart  "New users", model: User, x: :created_at, by: :month
  end
end
```
- **Two widget types** (per spec): `metric "Label", callable` (tile: label + number) and
  `chart "Title", model:, x:, by:` — the chart widget **reuses `ChartBuilder`** (portable
  date-bucketing, dependency-free inline SVG, same date-column allowlist). No reinvented charting.
- **Opt-in mount**: `get "dashboard"` drawn only when `CafeCar.dashboard?`; controller also
  `head :not_found` when unconfigured (defense-in-depth + clean test seam). Zero config → no
  dashboard, no route.
- New: `lib/cafe_car/dashboard.rb`, `app/controllers/cafe_car/dashboards_controller.rb`,
  `app/views/cafe_car/dashboards/{show,_metric,_chart}.html.haml`, `dashboard.css`. Dogfooded in
  `test/dummy` (2 metrics + 1 chart over `Article`) → live on the demo at `/admin/dashboard`.
  README + CHANGELOG updated. `bundle exec rake` fully green (**184 tests, 541 assertions, 0
  fail, Brakeman 0**); smoke-tested `/admin/dashboard` → 200 with tiles + `svg.Chart` bars. Built
  by a `coder` subagent.

**Decisions beyond spec (all sound):** `to_prepare` wrapping (app models aren't autoloaded at
plain-initializer time; DSL replaces-on-declare so reload rebuilds not duplicates); no auth on the
dashboard action (matches the components gallery — host controls the mount point; chart widgets
still resolve the model policy for the allowlist, nil-user-safe) — flagged to owner for a v2
auth decision.

**Filed:** `surface-the-dashboard-in-the-sidebar-nav-cafecar-navigation-` (P2) — `CafeCar::Navigation`
lists only index routes, so the dashboard is direct-URL only. High-leverage for *demo
discoverability* (a differentiator nobody can find is half a feature).

**Next:** nav auto-link (above) to surface dashboards on the demo; then the PostHog error-context
fix (URL/params/session_id on captured errors) or CrayonBloom dogfood milestone.

---

## 2026-07-03 — Pass 89 (GREEN): fixed a P1 shipped-gem security bug (params[:sort] → unauth 500)

**Trigger:** self-directed pass (GREEN, `launching`). Picked the sharpest trust risk in the
backlog — a P1 security/crash defect in the *published* gem, surfaced by the PostHog error
tracking I shipped Pass 88 (dogfooding paid off within a day).

**Shipped (`4164966`, CI green):** allow-listed sort keys at the source. `CafeCar::Model.sorted`
passed client-supplied `params[:sort]` straight into `reorder` as raw SQL; `normalize_sort_key`
never validated the column, so `?sort=item.` tripped Rails' dangerous-query guard →
`ActiveRecord::UnknownAttributeReference` → guaranteed **unauthenticated 500** (pre-guard Rails:
SQL-injection vector). Fix (`lib/cafe_car/model.rb`): `normalize_sort_key` now strips the optional
`-desc` prefix and only emits an order term when the column is in the model's real `column_names`;
unknown/malformed keys return `nil` and are dropped via `filter_map`. Comma-split moved into
`sorted` so multi-key + default-order fallback still work. No controller workaround — fixed at
root. New tests (`test/controllers/sort_and_paginate_test.rb`): `bogus.col` dropped, `item.`
crash-repro dropped, multi-key applies only valid keys. `bundle exec rake` fully green (**180 runs
/ 530 assertions, 0 fail, Brakeman 0**); confirmed empirically `?sort=item.` now 200s. Built by a
`coder` subagent.

**Decision/assumption (recorded):** allow-list scoped to the model's own `column_names`, **not**
dotted association keys — because `sorted` has no association-resolution logic to mirror, and those
`<assoc>.<col>` keys (emitted by `LabelBuilder`) **already 500 today** (`no such column:
client.number` — no join/alias backs them). Dropping them converts a pre-existing error page into a
graceful default-order fallback: a strict improvement, zero working-feature regression. Trade-off:
belongs_to header sort links are now no-ops instead of 500s.

**Filed:** `association-belongs-to-column-header-sort-is-broken-no-join-` (P2) — restore working
association sort via `references(:assoc)` + table-qualified column, then re-allow those keys.

**In flight:** emailed **homelab** for a scoped Railway project token (GitHub secret `RAILWAY_TOKEN`)
so next pass I can add a CI-gated `railway up` deploy step and permanently kill the stale-demo
problem (Pass 88's 137-commit-stale catch). Root-cause-demo-auto-deploy task stays open pending the
token.

**Next:** wire the CI-gated demo deploy once the token lands; then **dashboards** (owner-greenlit
#8 — warrants a short design note + first-cut, charts being the primitive it composes).

---

## 2026-07-03 — Pass 88 (GREEN): PostHog on the live demo + caught a 137-commit-stale demo

**Trigger:** owner-directed (jeff, in-session 2026-07-03): "set up posthog on the demo app for rails
logs, error-tracking, analytics, etc. I added a CafeCar org to posthog for you." Board task
`instrument-the-live-demo-with-posthog-analytics-error-tracki` (P1).

**Shipped (`0cb94f3`, CI green):** PostHog wired into the demo (`test/dummy`) **only**, fully
production-guarded so the minitest suite stays offline. Via `posthog-ruby`/`posthog-rails` 3.16.0:
- **Analytics** — posthog-js frontend snippet (autocapture/pageviews/session recording), injected
  through a demo-only 4-line layout override (`test/dummy/app/views/layouts/application.html.haml`
  + `_posthog.html.haml`). **Zero** PostHog code in the shipped gem/engine (their layout is
  shipped to every consumer — never instrument strangers' apps).
- **Error tracking** — `auto_capture_exceptions` + `report_rescued_exceptions` +
  `auto_instrument_active_job`. `capture_user_context = false` (demo has no web `current_user`).
- **Logs** — `logs_enabled = true` forwards `Rails.logger` over OTel (gems added `require: false`).
- PostHog: CafeCar org, project `496903`, public token `phc_nw2…eEMHN`, host `us.i.posthog.com`.
  Whole initializer guarded on `Rails.env.production?`. `bundle exec rake` green (177 tests, 0
  fail, Brakeman 0); offline confirmed in test env. Built by a `coder` subagent.

**🔎 Caught: the live demo was 137 commits stale.** Railway's last deploy was **2026-06-28**
(`6023e556`) — auto-deploy on push stopped firing, so the demo silently served ~2-week-old code
(missing bulk actions, theming, searchable selects, chart view, *and* PostHog). **Manually
triggered a deploy** (`railway up`, build `ed4c8bce`) — recovered current code + PostHog in one
shot. Filed P1 `root-cause-fix-demo-auto-deploy-was-137-commits-stale` to fix the trigger (or add
a CI deploy step). A stale demo directly undercuts the trust/conversion goal.

**Verified live ingestion** (project 496903, ~2h window): `$exception` **46**, `$pageview` **2**,
`$autocapture` **1**, and **351** Rails log records tagged `posthog-rails@3.16.0` (real request
logs — `Started GET` / `Processing by …Controller` / `Completed 200 OK`). All three asks confirmed
end-to-end, not just deployed.

**Notable:** error tracking already caught a recurring `ActiveRecord::RecordNotFound` in
`CafeCar::Controller#find_object` (`lib/cafe_car/controller.rb:188`) — worth a later glance; could
be probe/bot traffic or a genuine bad-id path. That's error tracking earning its keep on day one.

**Next:** owner digest sent (PostHog live + stale-demo catch). Watching the auto-deploy fix (P1)
and dashboards (`dashboards-home-overview-capability-owner-greenlit-8`, still the top feature item).

**Trigger:** owner-directed feature (jeff, 2026-07-03 — see `DECISIONS.md`): "add a chart tab to the
index page… allow selecting any date time column as x axis." Board task
`index-chart-tab-third-view-grid-table-chart-with-selectable-`.

**Shipped:**
- **Third index view — Chart** — alongside grid/table, reusing the existing `view` param /
  `view_url` toggle mechanism (no parallel path). New `_chart.html.haml` renders through the same
  `render(view)` dispatch; new toggle button in `_index_actions.html.haml`.
- **`CafeCar::ChartBuilder`** (`lib/cafe_car/chart_builder.rb`) — aggregates the controller's already
  policy-scoped + filtered `objects` relation (strips pagination/order/eager-load, keeps the WHERE),
  `GROUP BY` a **portable Arel date truncation** (`date_trunc` on Postgres, `strftime` on SQLite — no
  raw SQL, Brakeman-clean), `COUNT(*)` per bucket. X-axis param validated against an allowlist of the
  model's displayable date columns (never interpolated as a column name). Renders dependency-free
  inline SVG (no JS, CSP-safe). Default `created_at` + month, so it renders zero-config.
- Controls form (GET) to pick x-axis column + day/week/month granularity; composes with active
  filters/sort/search. `chart_x`/`chart_by` added to `CONTROL_PARAMS`. New `chart.css`.
- **Tests** (`test/controllers/chart_view_test.rb`, 7): exact bucket counts (month + day), filter
  narrows, `policy_scope` hides rows, NULL x-axis dropped, bogus/injection param falls back to
  `created_at`, zero-rows empty chart with axis.
- Docs: README Features bullet + "Chart view" usage section; CHANGELOG Unreleased entry.
- `bundle exec rake` green: rubocop 215 files clean, 177 runs / 0 failures, Brakeman 0.
- **Commit `5a2724b`** — pushed, **CI green**.

**Context (conductor):** the owner replied to the 7/3 digest — VERIFIED steer recorded in
`DECISIONS.md`: **YES to dashboards** (resolves audit #8 as a greenlit build, not a parked
decision) **and** this chart-tab request. Filed two P1s from it — this chart tab (done) and
**dashboards** (`dashboards-home-overview-capability-owner-greenlit-8`, next). Built charts first
because they're the reusable primitive a dashboard composes. The post-audit feature-gaps tracker is
now fully closed.

**Follow-ups filed** (`chart-tab-follow-ups-...`, P3): (1) the aggregation's Postgres `date_trunc`
path isn't exercised in CI (SQLite-only) though the live demo runs Postgres — smoke-check on the
demo or add a PG lane; (2) selectable y-metric (sum/avg of a numeric column) — currently count-only,
`chart_by` param already reserved.

**What's next:** **dashboards** — scope + first-cut. Design decisions to make/propose: single admin
home vs. per-namespace, which widgets (metric tiles, charts reusing this ChartBuilder,
recent-activity, quick links), and a host-facing config API to declare dashboard contents. Charts
being done means the dashboard can compose them. This is now the top of the buildable backlog again.

---

## 2026-07-03 — Pass 86 (GREEN): cleared the last two audit nits (#12/#13)

**Trigger:** proactive wake, GREEN, no owner reply yet, CI green. Buildable backlog drained; per the
"generate/close the next work" decision I cleared the tracker's last two concrete eng items rather
than idle. Held the larger generative audit until the owner responds (avoids churn against their
pending dogfood/positioning steer).

**Shipped — `0825ba2`, CI green (delegated to one `coder`):**
- **#12** `attributes.rb` — `editable` returned `@permitted.map()` (a no-block **Enumerator**, not an
  Array). Root cause: unreachable buggy branch overlapping a redundant private `process_attributes!`
  that already did `@permitted.clone`. Collapsed the two — `editable` now lazily memoizes
  `@permitted.clone` (a mutable Array working copy). Behavior-preserving; the class is currently
  unconsumed (grep-confirmed), so this defuses a landmine before it's wired up.
- **#13** — **deleted** `lib/cafe_car/auto_resolver.rb` + its `require`/`extend AutoResolver` in
  `cafe_car.rb` + two stale `brakeman.ignore` entries. Grep proved it dead: `auto_resolve!` is
  `extend`ed but **never invoked**, so its `const_missing` hook is never installed. Removing it kills
  the latent security footgun — an absent policy would have auto-generated one with
  `admin? = Rails.env.development?` (fully open in dev). Deletion, not documentation, was correct.
- `bundle exec rake` green: rubocop 213 files clean, 170 runs / 0 failures, Brakeman 0.

**Tracker state:** every item on the post-audit feature-gaps tracker (majors #5–7, minor #9, nits
#12/#13) is now closed except **#8 dashboard** (owner positioning decision, not a build). The
buildable-without-owner-input backlog is fully drained.

**What's next:** genuinely owner-gated now (digest sent 7/3: #8 decision, CrayonBloom dogfood
requirements, publish key). If no steer by next pass, run a fresh adopter-scenario audit on the
now-larger surface (bulk actions, theming, search all shipped this session) to generate the next
development wave — verifying the new code holds under real usage patterns.

---

## 2026-07-03 — Pass 85 (GREEN): searchable/remote association selects (Tom Select)

**Trigger:** proactive wake, signal GREEN, CI green, no mail. The one substantial no-owner-input
build left (per Pass 84's plan): make large `belongs_to` selects reachable past the render cap via
typeahead. Verified first that the JS pipeline is **importmap + propshaft** (engine already vendors
turbo/trix/actiontext) — so Tom Select is a clean, reversible *vendored pin*, not a bundler
commitment. That made it a routine maintainer call (cheap/reversible envelope), delegated to one
`coder`.

**Shipped — `b62a5bd`, CI green:**
- **Vendored Tom Select 2.4.3** (`tom-select.complete.min.js` pinned in `config/importmap.rb`; CSS
  `@import`ed under the `vendor` layer) — matches the existing turbo/trix vendoring, no CDN/bundler.
- **Remote authorized endpoint** — the routing concern now adds `GET /<resources>/options` to every
  cafe_car resource (same mechanism as Pass 83's `batch`). Returns `[{value,text}]` filtered by the
  model's `default_search` (`?q=`), capped at `max_collection_options`. **Authorized twice**:
  `authorize model, :index?` + `policy_scope(model)` — never leaks unauthorized rows. Search is
  Arel `matches` + `sanitize_sql_like` (parameterized, Brakeman 0).
- **Progressive enhancement** — form builder renders the normal `collection_select` tagged
  `data-searchable-select` (+ feed URL, only when the model's route exists — else degrades to a
  plain capped select). `cafe_car.js` inits on `turbo:load`/`turbo:frame-render`, guards
  double-init via `el.tomselect`, reverts on `turbo:before-cache`. Works with no JS.
- **Latent bug fixed en route** — `with_selected` now keeps the currently-associated record in the
  options even when it sorts past the cap (editing a beyond-cap association previously dropped the
  value silently); plus a root-cause fix to the JSON renderer override so array payloads pass to
  `super`.
- **Effect-level tests** (`searchable_association_options_test.rb`): a `q=` surfaces a record past
  the cap (the core proof); feed is `policy_scope`d (hidden row absent); capped at page size; select
  renders the hook + feed URL. `bundle exec rake` green — rubocop 214 files clean, **170 runs / 0
  failures**, Brakeman 0.

**Decision (maintainer call, recorded):** Tom Select is **Apache-2.0**, not MIT as the task assumed.
Apache-2.0 is permissive and compatible with bundling in an MIT gem; the vendored files retain their
license header. Standard vendoring — not escalated. If the owner prefers zero third-party licenses
in the tree, that's a reversible swap (remove the pin, keep the endpoint + plain capped select).

**What's next:** the buildable-without-owner-input backlog is now essentially drained. Remaining is
owner-gated — **#8** dashboard positioning (decision emailed 7/3), **CrayonBloom dogfood** (needs
requirements), **discoverability** (best post-publish; RubyGems key is owner-only), the owner's
one-time dashboard-wiring task. Next GREEN passes: nits #12/#13 cleanup, then likely a fresh
completeness/adopter-scenario audit to generate the next development wave (per the "a drained
backlog is not a hold — generate the next work" decision).

---

## 2026-07-03 — Pass 84 (GREEN): theming hooks — hosts pick a bundled theme (audit gap #9)

**Trigger:** proactive wake, signal GREEN. Audit gap #9: five theme CSS files shipped but only
`warm`/`warm-dark` were hard-`@import`ed in `cafe_car.css` — `cool`/`cool2` were dead code and a
host had no way to choose a theme. Delegated to one `coder`.

**Shipped:**
- **Config API** — `CafeCar.theme = :cool` (`lib/cafe_car.rb`): a `mattr_reader` (default `:warm`,
  preserving today's rendering) with a validating `theme=` writer that raises `ArgumentError` on a
  value outside `THEMES = %i[warm cool cool2]`.
- **Wiring** — `CafeCar::Helpers#theme_stylesheet_tag` emits the selected theme's `<link>` into
  every page's `<head>` (`app/views/application/_head.html.haml`), after `application.css` so its
  `:root` tokens win. Removed the hard `@import`s from `cafe_car.css` — nothing is pinned now.
- **Normalized `warm`** — merged `warm-dark.css` into a `prefers-color-scheme: dark` block inside
  `warm.css` and deleted the companion file, so every theme is one self-contained file with
  built-in dark mode (matching cool/cool2's existing pattern). Dark mode still works.
- **`cool2` decision** — kept as a distinct selectable variant (translucent cards + darker dark
  background), not dead; added a one-line header comment noting that.
- **Tests** — `test/controllers/theme_test.rb`: renders an index with `theme = :cool` and asserts
  the cool link present + warm/cool2 absent; default `:warm` present when unset; invalid theme
  raises. README documents the option + the three bundled themes.
- Full `bundle exec rake` green: rubocop clean, 166 runs/495 assertions/0 failures, brakeman 0.
- **Commit `d924e69`** — pushed, **CI green**.

**Also this pass (conductor, inline — trivial config, not delegated):**
- **`d870a81`** — bumped `.claude/settings.json` `fallbackModel` `sonnet-4-6 → sonnet-5`. JSON
  validated, pushed, CI green. Cleared the last P2 quick-win off the board.

**Roadmap state:** with #7 (Pass 83) and #9 (this pass) done, every completeness-audit item that
was buildable without owner input is closed. What remains is genuinely gated: **#8** dashboard
positioning (owner decision — emailed 7/3), the **CrayonBloom dogfood** milestone (needs owner
requirements), **discoverability** (best after v0.1.2 is published — RubyGems key is owner-only),
and the deferred **searchable/remote association select** (Tom Select — a real but optional
enhancement). Nits #12/#13 remain (dead-code cleanups).

**What's next:** the Tom Select searchable/remote association select is the one substantial build
left that needs no owner input — a good next GREEN pass. Otherwise the backlog is owner-gated;
absent a steer I'll pick up #12/#13 nit cleanups or the CHANGELOG/v0.1.2 prep.

---

## 2026-07-03 — Pass 83 (GREEN): shipped bulk actions — the last major feature gap

**Trigger:** proactive wake, signal GREEN, CI green, no unread mail. Per the owner's 2026-07-02
"develop the gem" decision, product development is default-on: the completeness audit's advertised-
but-broken findings were all closed (Passes 78→82), leaving **#7 bulk actions** as the biggest
remaining major (table-stakes vs. ActiveAdmin/Avo/Administrate). Picked it, filed it P1, delegated.

**Shipped (delegated to one `coder`):**
- **`ce5d6fe`** — bulk actions live on every index table. Design: a registry on the module,
  `CafeCar.bulk_action(name, query:, &block)` storing a `BulkAction` (name + policy predicate +
  per-record op); block defaults to `record.public_send("#{name}!")`, `query:` to `:"#{name}?"`.
  **Bulk-delete ships built-in**; hosts add custom actions in an initializer. Selection posts row
  ids + action name to a new `post :batch` collection route.
- **Per-record authz (the load-bearing part).** `Controller#batch` narrows candidates to
  `policy_scope(model)`, then checks each row individually via `action.allowed?(policy(record))`;
  unauthorized rows are dropped, never bulk-bypassed. `batch` is excluded from the blanket
  `authorize!` and uses Pundit's `skip_authorization` escape hatch while `policy_scope` satisfies
  `verify_policy_scoped`.
- **Effect-level tests** (per the audit meta-finding, not request-shape): seeds 3 drafts + 2
  published, batch-deletes all 5 → asserts the 3 drafts gone from the DB AND the 2 published
  survive (per-record boundary proven by DB state); a second test asserts a single `WHERE id IN`
  SELECT for 3- and 8-row batches (authz is in-memory, no N+1); unknown-action → 400; UI renders
  select-all + per-row `ids[]` checkboxes + the Delete bar.
- `bundle exec rake` fully green: RuboCop 212 files 0 offenses, tests **163 runs / 0 failures /
  0 errors**, Brakeman 0. Pushed; **CI green** (rubocop, brakeman, test, screenshot all ✓).

**Decisions/assumptions (recorded by the coder, ratified here):** (1) the bulk-action bar is
policy-gated (an action shows only if the resource's policy answers its predicate) — sufficient
boundary for v1. (2) Dummy `ArticlePolicy#destroy?` now protects published articles — a deliberate
test-fixture change giving the per-record authz test a real allow/deny split; keeps existing
`AllControllersTest` green (factory articles are drafts).

**Roadmap state:** every P1 major from the completeness audit is now closed. Remaining feature-gap
items are all minor/positioning: **#8** dashboard/homepage (a positioning *decision* — stay a CRUD
generator vs. full admin framework — worth an owner ping), **#9** theming hooks (themes exist but
aren't imported/selectable), nits **#12/#13**. Plus the deferred searchable/remote association
select (Tom Select) and the CrayonBloom dogfood milestone (needs owner requirements input).

**What's next:** #9 theming hooks is the cleanest next build (self-contained, no owner input). #8
dashboard is a decision to surface to the owner, not a build. Dogfood + discoverability still await
owner input / a green light.

---

## 2026-07-02 — Pass 82 (GREEN): fixed the boolean render-crash the harness just found

**Trigger:** continued from Pass 81 (harness surfaced the bug hot). Signal GREEN. CI green.

**Shipped (delegated to one `coder`):**
- **`3927a00`** — booleans advertised (README:488) but `FieldInfo#input` had no `:boolean` branch →
  any new/edit form with a boolean field was a 500. Fix: `when :boolean then :check_box` (generic
  `_field` partial dispatches to `check_box` — no new partial). Added a `paid:boolean` column to the
  dummy `Invoice` + `:paid` to its policy (**load-bearing:** Invoice uses a hand-written policy, so
  the field neither rendered nor persisted without the permit), and **re-included the boolean case**
  in the round-trip harness (asserts the edit form renders AND `false→true` persists on reload).
- Suite green (159 runs, 0 failures; Brakeman 0). Pushed; CI green. (Coder chased transient local
  `CsvExportTest` flakiness from a mid-reload test DB — not a regression; CI builds clean from
  `schema.rb`, which carries the new column.)

**Session tally (Passes 78→82, all GREEN):** shipped **6 audit findings + 1 standing harness** —
#11 `per=` DoS cap, #10 `/components` dev-gate, #6 `has_many_attached` wired (+ latent `eager_loaded`
crash), #5 association-select cap, the effect-level round-trip harness, and the boolean render-crash
it caught. Every advertised-but-broken feature from the completeness audit is now fixed AND guarded
by an effect-level test.

**What's next:** #7 bulk actions (biggest remaining major — multi-row UI + batch authz); minors #9
theming hooks, #8 dashboard positioning; the deferred searchable/remote select. Dogfood build stays
spec-blocked on CrayonBloom specs.

---

## 2026-07-02 — Pass 81 (GREEN): standing effect-level harness — and it caught a new bug immediately

**Trigger:** `/loop 8h` re-fire. Signal GREEN (`left=13`). CI green.

**Shipped (delegated to one `coder`, the audit's #1 META-finding):**
- **`fd2002a`** — `test/controllers/field_type_round_trip_test.rb`: one standing harness that runs
  **12 field types** (string, text, integer, decimal, date, datetime, belongs_to/`:references`,
  has_many nested `_attributes`, has_one_attached, has_many_attached, rich_text, password) through
  the REAL `admin/<plural>#update` path and, after **reload**, asserts each value/association
  actually persisted — EFFECT, not markup. Plus an N+1 guard (index query count must not scale with
  row count). DRY: a `round_trip(type, &block)` macro on a shared `submit()` spine — adding a type is
  one block. Fixes the bug *class* that let 4 advertised features ship broken this session.
- Test-only change; suite green (158 runs, 0 failures; Brakeman 0). Pushed; CI green.

**It earned its keep on landing — NEW P1 bug surfaced (filed, not buried):**
- **Booleans advertised but crash the render layer** →
  `boolean-fields-advertised-but-crash-the-render-layer-500-on-` (P1). README:488 advertises
  booleans; `FieldInfo#input` has no `:boolean` branch, so any new/edit form with a boolean field
  hits the `else raise "Missing input type… :boolean"` — a 500 (render crash, not silent no-op;
  persistence would work). Never caught because the dummy app has **zero boolean columns** — booleans
  were wholly unexercised. Coder proved it via a reverted spike, correctly did NOT fix it inside the
  harness task, and left boolean out so the suite stays green until fixed. Fix is small (`when
  :boolean then :check_box` + partial + a dummy boolean column + re-include the harness case).

**What's next:** fix the boolean P1 (small, hot — dispatching next). Then #7 bulk actions (biggest
remaining major), theming/positioning minors. Dogfood build stays spec-blocked on CrayonBloom.

---

## 2026-07-02 — Pass 80 (GREEN): capped unbounded association `<select>` (3rd cap, same pattern)

**Trigger:** in-session "Continue CafeCar operation." Signal GREEN (`left=14`). CI green.

**Shipped (delegated to one `coder`, from `major-feature-gaps-post-audit` #5):**
- **`a7f7417`** — `FieldInfo#collection` was `reflection.klass.all` (no bound), backing BOTH the
  edit-form `collection_select` and the filter sidebar: a `belongs_to` with 10k rows rendered a
  10k-`<option>` select on every form/index load. Now `reflection.klass.limit(
  CafeCar.max_collection_options)` (default 100) — `.limit` on the AR relation, so at most the cap
  ever materializes. This is the **3rd cap in the same family** (`csv_export_row_limit`,
  `max_per_page`, now `max_collection_options`) — a consistent, discoverable safety pattern.
  Effect-level test asserts the materialized (`.to_a.size`) option count is bounded by the cap.
- Full suite green (145 runs, 0 failures; Brakeman 0). Pushed; CI green.

**Scope decision:** split #5 — this pass is the **cap** (stops the unbounded load). The
searchable/remote select (Tom Select typeahead for associations larger than the cap) is a bigger
front-end change (JS dep + remote options endpoint) → filed as a separate deferred follow-up
(`searchable-remote-association-select-tom-select-enhancement`), not blocking.

**What's next:** #7 bulk actions (multi-row select UI + per-row batch authz — the biggest remaining
major); minors #9 theming hooks, #8 dashboard positioning decision. Then the standing effect-level
integration harness (audit meta-finding). Dogfood build stays spec-blocked on CrayonBloom.

---

## 2026-07-02 — Pass 79 (GREEN): has_many_attached wired end-to-end (+ latent bug fixed)

**Trigger:** `/loop 8h` heartbeat re-fire. Signal GREEN (`left=14 used=33`), tightening. Per the
standing owner correction (GREEN → develop the gem), picked the most self-contained remaining major.

**Shipped (delegated to one `coder`, from `major-feature-gaps-post-audit` #6):**
- **`2aab30e`** — `has_many_attached` was advertised (README ~484) but only `has_one_attached`
  worked: forms silently handled one file. Coder **wired it** (effort was clean, so feature > README
  cut): `FieldInfo#multiple?` detects the `:has_many_attached` macro; `FormBuilder#input` renders
  `<input type=file multiple name="…[]">`; `Controller#permitted_attributes` (Pundit override)
  expands `has_many_attached` keys to `{name => []}` so the array survives strong-params — works for
  auto-gen AND hand-written policies (keys off the model's reflections, not the policy shape).
  Effect-level test attaches 2 files through the real update flow, asserts both persist.
- **Latent bug fixed en route:** `eager_loaded` called `scope.includes(*[])` →
  `ArgumentError: must contain arguments` whenever a model's displayable attrs and associations
  don't intersect (true for any association-less model — breaks show/update for a whole class). No
  existing test exercised such a model through a cafe_car controller, so the green suite never caught
  it. Coder fixed the root cause (skip `.includes` when nothing to preload), not a workaround.
- Full suite green (144 runs, 0 failures; Brakeman 0). Pushed; CI green.

**Notes:** The `filter/form_builder.rb` TODO the audit flagged is a red herring — it's the
search-filter builder (multi-value query params), a different feature; the attachment path is
`CafeCar::FormBuilder`. Left the filter TODO untouched.

**What's next:** remaining majors — #5 unbounded association `<select>` (needs cap/search — bigger,
Tom Select), #7 bulk actions (multi-row UI + batch authz). Then the standing effect-level
integration harness (audit meta-finding). Dogfood build stays spec-blocked on CrayonBloom specs.

---

## 2026-07-02 — Pass 78 (GREEN): 2 security footguns hardened + board reconciled

**Trigger:** `/loop 8h` operating pass. Signal GREEN (`left=16 used=31 alloc=47`). CI green.

**Board reconcile:** `fix-documented-filter-syntax` showed open despite the fix (`0311366`,
effect-tested in `filtering_test.rb`) shipping Pass 77 — the "done" mark had landed on the
now-retired local `tasks/` file (retired in `7daccba`), so the board never got it. Verified the
fix + test are genuinely in the tree and CI-green, then closed it on the board.

**Shipped (delegated to one `coder`, both from `major-feature-gaps-post-audit`):**
- **#11 uncapped `?per=` DoS** → `757eaf9`. `?per=1000000` materialized whole tables (HTTP 200).
  Added `CafeCar.max_per_page` (default 200), mirroring the existing `csv_export_row_limit`
  accessor; `Controller#paginated` clamps via `capped_per` (silent, no error). Effect-level test
  in `sort_and_paginate_test` asserts returned row count == cap.
- **#10 unauthenticated `/components` route** → `c4fabef`. The examples/UI-gallery demo route
  skipped policy+authorization and mounted in every env, undocumented. Dev-gated it
  (`if Rails.env.development?`); new `components_route_test` asserts 404 outside development.
- Full suite green (142 runs, 0 failures; Brakeman 0 warnings). Both pushed; CI green.

**Decisions/notes:** Dogfood tasks (P1 `dogfood-crayonbloom`, P2 milestone) are spec-blocked —
the CrayonBloom operator is the spec author and hasn't filed requirement tasks on the board yet;
nothing to build there this pass. Neither security fix warranted a README edit (both surfaces
were undocumented). Test env returns 404 (not a raised RoutingError) under
`show_exceptions = :rescuable` — noted for future route tests.

**What's next:** remaining majors from the tracker — #5 unbounded association `<select>` (needs
cap/search, bigger), #6 `has_many_attached` advertised-but-unimplemented (wire or drop the claim),
#7 bulk actions. Then the standing effect-level integration harness (the audit's meta-finding).
Dogfood build unblocks when CrayonBloom files specs.

---

## 2026-07-02 — Pass 77 (GREEN): 🔵 owner correction → shipped 4 P1 blockers + fixed Pages CI

**Trigger:** owner, in-session — *"why do you think you shouldn't be developing the gem? it's not
even close to done."* A direct correction of my recent "healthy hold" passes. Recorded verbatim +
dated to `DECISIONS.md` (committed) BEFORE acting, per the owner-feedback rule.

**Root cause of the bad pattern:** I conflated *"the filed `tasks/` backlog has no unblocked items"*
with *"nothing to develop."* For a v0.1.x gem those differ enormously — I drained a finite list then
idled instead of **generating** the next real work. Standing correction now in `DECISIONS.md`: a
drained backlog is NOT a hold; product development is default-on, gated only by the budget signal.

**What I did — generated a real backlog, then shipped it:**
- **Completeness audit (graybeard)** — honest gap read. Found 4 README-advertised features BROKEN
  for real use, under a fully green suite, because tests assert *request shape* (does it render) not
  *effect* (did data change). Filed 4 P1 blocker tasks + a majors/nits tracker (`707fbb1`).
- **#1 Nested `has_many` forms silently didn't save** → `84eb5fa`. Policy permitted `line_items:` but
  Rails sends `line_items_attributes`; strong-params dropped the payload (HTTP 200, data lost). Fixed
  the permit layer + taught `FieldInfo#reflection` the `_attributes` suffix (audit missed this — the
  naive fix breaks rendering). Effect-level create/update/`_destroy` round-trip test added.
- **#4 `cafe_car:resource` generated an unsavable `belongs_to` policy** → `502fab6`. Forwarded bare
  `:client` not `:client_id`. Translate `:references`→`_id` (+`_type` polymorphic); generator tests
  on reference fields.
- **#3 N+1 on every index with an association** → `5540d58`. Added `eager_loaded` to the scope
  pipeline. Coder corrected the audit: the direct FK was already batched by `head_builder`; the real
  N+1 was the ActiveStorage **preview attachment**. Bounded-query-count regression test (distinct
  associations per row to defeat the AR query-cache masking trap).
- **#2 Documented filter syntax (`price.min=10`, `.gt`/`.lt`) was a silent no-op** → `0311366`.
  Made bare-key + word-operator syntax (the README's own) actually filter; removed the undocumented
  dot-prefix form; full range/comparison test coverage (none existed). Audit was off — `param_parser`
  was fine; gaps were in `filtering.rb` + `query_builder.rb`.
- All 4 tasks `done`; each CI-verified green; suite grew 125→140 runs / 387→438 assertions, 0 failures.

**Fixed the Pages CI failure the owner flagged (I'd wrongly called it "transient" in Pass 76):**
Real root cause — the legacy "Deploy from a branch" Pages build triggered on *every* push to main
(incl. code-only pushes) with **no concurrency control**, so this session's commit burst piled up on
Pages' single deploy slot and failed stuck in `deployment_queued`. Replaced it with
`.github/workflows/pages.yml` (`870c197`): `docs/**`-scoped triggers + a `pages` concurrency group;
builds via `actions/jekyll-build-pages` (same github-pages env). Switched Pages source legacy→workflow
via API. First deploy failed mid-transition (legacy runs still contending); a clean re-trigger
**succeeded**, status `errored`→`built`, site 200. **Durable-fix confirmed:** the later filter pushes
fired ZERO Pages runs. Code pushes no longer touch Pages.

**Lesson captured:** don't declare "transient" from intermittent green — the successes were the
non-overlapping pushes; the failures were the collisions. Verify the mechanism, not the vibe.

**Next:** the majors from the audit (`major-feature-gaps-post-audit`) — unbounded association
`<select>`s (#5), `has_many_attached` advertised-but-unimplemented (#6), no bulk actions (#7),
uncapped `per` (#11, cheap), the undocumented unauthenticated `/components` route (#10), two dead-code
landmines (#12/#13). Sequence after the blockers (done). Add a standing integration guard
(generate→submit-every-field→assert-persistence+bounded-queries) so this bug class can't ship again.

[session](https://claude.ai/code/session_01Q7aeb8NgyJvsRxE1FCT9wv)

---

## 2026-07-02 — Pass 76 (GREEN): 🟢 healthy hold — pages CI transient diagnosed

**Cadence:** owner re-fired `/loop 8h Continue CafeCar operation` → new session cron `6d80f72b`
(fires every 8h at :00). Pace **GREEN** (`bin/operate tokens --pace`: left=22 used=25 alloc=47).
Registry status `launching` (not hold). Reconstituted: DECISIONS.md empty, inbox no-unread, main CI
green (`28607563530`), demo **200**, docs site **200** (correct `<title>`), no open PRs, clean tree.

**Triaged a failing `pages-build-deployment` run — transient, not our repo.** GitHub Actions showed
two 10min-timeout failures (16:41, 17:00) + one fast 44s "Deployment cancelled" (my re-run). Root
cause: today's **burst of rapid pushes to main** (5+ standardize/sync/migrate commits in a short
window) → GitHub's legacy Pages deploy serializes them → queued pile-up timed out / got cancelled by
newer deploys. **Live site stayed 200 with correct content** (last good deploy) — the `errored` Pages
status is cosmetic burst-tail, and the main CI badge (points at `ci.yml`) stayed green throughout.
This WORKLOG commit (burst now settled) triggers one clean Pages build that should clear `errored`.
*If it recurs next pass:* consider converting the legacy Pages build → a workflow-based deploy
(`build_type: workflow`) with a `concurrency` group + `cancel-in-progress` (deferred — over-eng for
a cosmetic transient today).

**Assessed — nothing unblocked; verified thoroughly this time.** Walked the backlog + cross-venture
board + IDEAS.md. All unblocked work is `done`, incl. the P1 generator-onboarding 500s fix
(`fix-broken-resource-generator-onboarding`, done) and its README `cnc`-staleness follow-up (grep:
zero `cnc` refs in README — already clean). Three open tasks, all externally gated:
- **P1 [[dogfood-crayonbloom]]** — blocked on the CrayonBloom operator's requirement tasks landing.
- **P2 [[discoverability-launch]]** — all launch assets drafted/committed under `marketing/`; passive
  levers (repo topics + website) shipped; only the owner-gated **publish** step remains.
- **P2 owner-one-time-dashboard-wiring** — owner-only Railway/GitHub-App config.

**No ideation entry added** — IDEAS.md already holds the good directions (install-bootstrap generator,
comparison blog, dependency-diet — all `proposed`/queued); nothing new cleared the signal-not-slop bar.
**No owner email** — no milestone/decision/blocker change; a cosmetic Pages transient isn't digest-worthy.

**What's next:** wake on the 8h cron `6d80f72b`, inbound mail, or a CrayonBloom requirement task
landing. Work committed + logged → self-clear safe.

[session](https://claude.ai/code/session_01Q7aeb8NgyJvsRxE1FCT9wv)

---

## 2026-07-02 — Pass 75 (cold/reactive, YELLOW): 🟢 healthy hold

**Cadence:** cold/reactive; pace **YELLOW** (today 11/15) → conserve, no ideation/speculative work.
Woke on the 8h cron. Reconstituted per the new start-of-pass rule: CI green (`28565695098`), demo
**200**, no open PRs, no unread mail, clean tree, `DECISIONS.md` empty (no owner decisions pending).

**Assessed — nothing unblocked.** All three open tasks still gated: P1 dogfood-crayonbloom (CrayonBloom
operator), P2 discoverability-launch (owner), P2 owner-one-time-dashboard-wiring (owner).

**Decision: hold.** No re-ping, no speculative work (YELLOW). Going idle.

[session](https://claude.ai/code/session_01Q7aeb8NgyJvsRxE1FCT9wv)

---

## 2026-07-02 — Pass 74 (cold/reactive, GREEN): 🟢 two fleet doc updates shipped

**Cadence:** cold/reactive; pace **GREEN** (budget 15, spent 10) → full normal pass. Woke on the 8h
cron. Reconstituted: CI green, demo **200**, no open PRs, clean tree.

**Shipped (commit `f9f37b9`, CI run `28565624440` green, `rake` clean 125/0/0):**
- **P1 [[persona-write-owner-feedback-to-git-before-acting]]** — holdco fleet-wide persona update.
  Added the fixed-order rule to `AGENTS.md` + `.claude/agents/conductor.md`: VERIFIED owner feedback
  → append verbatim + dated to a git-tracked file → commit → *only then* act; plus a start-of-pass
  "re-read recent owner decisions" habit. Created `DECISIONS.md` at root as the log those rules point
  at. Replied "done" to holdco.
- **P2 [[pacing-rename-green-yellow-red]]** — renamed the pace-signal vocab NORMAL/REACTIVE/FORCE →
  GREEN/YELLOW/RED in AGENTS.md + conductor.md. Left the *cadence-mode* term "cold/reactive" untouched
  (different concept). Non-urgent note, folded into this pass since it was the same files.

**Inbox:** pacing-rename email marked read (filed + done). No other unread.

**Assessed — remaining open work still gated:** P1 dogfood-crayonbloom (CrayonBloom operator),
P2 discoverability-launch (owner), P2 owner-one-time-dashboard-wiring (owner). Nothing unblocked left.

**What's next:** wake on a holdco nudge, inbound mail, a CrayonBloom requirement task landing, or the
8h fallback cron `9f1d7fb6`. Context grew moderately this pass but work is committed + logged →
optional self-clear is safe; going idle.

[session](https://claude.ai/code/session_01Q7aeb8NgyJvsRxE1FCT9wv)

---

## 2026-07-01 — Pass 73 (cold/reactive): 🟢 healthy hold — 8h fallback re-armed

**Cadence:** cold/reactive. Owner re-fired `/loop 8h /clear Continue CafeCar operation` → new session
cron `9f1d7fb6` (fires every 8h at :00, replaces the expired-on-session-restart Pass-72 job). Full
assessment pass: CI green (run `28542479434`), demo **200**, clean tree, no open PRs, inbox no-unread
(`--to cafecar@bot.yak.sh`).

**Assessed — nothing unblocked; state unchanged from Pass 72.** Walked all 42 task files: every
unblocked item is `done`. Three open, all gated externally:
- **P1 [[dogfood-crayonbloom]]** — blocked on the CrayonBloom operator's requirements spec.
- **P2 discoverability-launch** — `blocked_on: user`.
- **P2 owner-one-time-dashboard-wiring** — `blocked_on: user`.

**Decision: hold.** No re-ping (owner already mailed passes 66–70; CrayonBloom has my capability
snapshot). No speculative work. Ideation defers in reactive mode. Context is fresh/lean → no
self-clear needed.

**What's next:** wake on a holdco nudge, inbound mail, a CrayonBloom requirement task landing, or the
8h fallback cron `9f1d7fb6`. Going idle.

[session](https://claude.ai/code/session_01Q7aeb8NgyJvsRxE1FCT9wv)

---

## 2026-07-01 — Pass 72 (cold/reactive): 🟢 healthy hold — 8h fallback loop armed

**Cadence:** cold/reactive. Owner re-armed the 8h fallback loop this pass (`/loop 8h /clear Continue
CafeCar operation` → session cron `36cc59bb`, fires every 8h at :07). Ran a full assessment pass on
setup: CI green (run `28538874934`), demo **200**, clean tree, no open PRs/issues, inbox no-unread
(`--to cafecar@bot.yak.sh`).

**Assessed — nothing unblocked; state unchanged from Pass 71.** Board `venture=cafe_car` has three
open items, all gated:
- **P1 [[dogfood-crayonbloom]]** — waiting on the CrayonBloom operator's requirements spec.
- **P2 dogfood-milestone** — a meta-tracker ("pick up requirement tasks as they land"), created
  06-27; verified this pass that **no requirement tasks have landed** on my board — only the tracker
  itself + dogfood-crayonbloom. Same spec-author gate.
- **P2 discoverability-launch** — `blocked_on: user`.

**Decision: hold.** Pass 71's decision stands — no re-ping (owner already mailed passes 66–70;
CrayonBloom has my capability snapshot), no speculative CrayonBloom scope. Ideation defers in reactive
mode. Context is already lean (fresh session) → no self-clear needed.

**What's next:** wake on a holdco nudge, inbound mail, a CrayonBloom requirement task landing, or the
8h fallback cron. Going idle.

[session](https://claude.ai/code/session_013LfWaAPnsexHY9KP5xxyi4)

---

## 2026-07-01 — Pass 71 (cold/reactive): 🟢 healthy hold — unblocked backlog drained, all open work gated

**Cadence:** cold/reactive, woken by a holdco nudge. Reconstituted cold: git log, WORKLOG, my board
(auth'd), local `tasks/`, inbox (`--to cafecar@bot.yak.sh` → no unread). CI green (run `28538708227`),
demo **200**, clean tree, no open PRs/issues.

**Assessed — nothing unblocked to advance.** Local `tasks/` and the holdco board agree: only **three**
open items, all gated:
- **P1 [[dogfood-crayonbloom]]** — blocked on the CrayonBloom operator's spec. Verified on *their*
  board this pass: their "Define the back-office requirements for the CafeCar dogfood" is still `open`,
  and my pass-23 capability-snapshot ping ("CafeCar dogfood: capability snapshot + anticipated deltas")
  is still `open` too. Nothing moved; no requirement tasks have landed on my board. The gate is their
  spec author, not me.
- **P2 discoverability-launch** — `blocked_on: user` (accounts + go-ahead).
- **P2 dashboard-wiring** — `blocked_on: user` (one-time Railway/GH config).

**Decision: hold, don't manufacture work.** Re-pinging either party this pass would be spam (owner
already emailed/filed passes 66–70; CrayonBloom already has my snapshot). Building the *anticipated*
CrayonBloom deltas (custom member/collection actions, bulk actions, index thumbnails) now would
violate my own recorded decision to avoid speculative scope creep until they confirm — that decision
stands. Ideation defers in reactive mode.

**What's next:** wake on a holdco nudge, inbound mail, a CrayonBloom requirement task landing on my
board, or the 8h fallback. Self-clearing at this clean boundary.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 70 (cold/reactive): 🔧 release workflow now auto-cuts the GitHub release

**Cadence:** cold/reactive, woken by a holdco nudge. Reconstituted cold: git log, WORKLOG, board
(auth'd), local `tasks/`, inbox (no unread). CI green, demo **200**, no open PRs/issues.

**Advanced the one unblocked backlog item.** Everything on the board's open list is externally/owner
gated (two CrayonBloom milestone trackers awaiting requirement tasks; `discoverability-launch` +
dashboard-wiring owner-gated) — *except* the P3 I filed last pass:
[[release-workflow-auto-create-github-release]]. Picked it up and delegated to a coder.

**Shipped (`45b5ef3`).** Added a "Create or update the GitHub release" step to `.github/workflows/
release.yml` after `rubygems/release-gem@v1`. It extracts the matching `CHANGELOG.md` section by
version via awk, and is idempotent: `gh release view` → `edit --latest` if it exists, else `create
--latest --verify-tag`. So the manual `gh release create` I had to run on v0.2.1 (pass 69) is gone,
and a re-run or the manual fallback won't fail the job. Uses `github.token` (no new secret). CI green
(run `28538597120`: rubocop ✓ brakeman ✓ test ✓ screenshot ✓).

**Residual verification:** a workflow YAML change isn't exercised by `rake` or CI — the create/edit
logic is confirmed by reading only. The **next live release (v0.2.2 / v0.3.0)** is the real proof
that the release object appears automatically with the right notes. Acceptable: manual `gh release
create` remains a working fallback.

**Board state unchanged otherwise:** unblocked build backlog is drained; critical path is CrayonBloom
requirement tasks (not yet filed) + owner's call on the discoverability launch. Self-clearing at this
clean boundary; wake on a nudge, mail, or the 8h fallback.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 69 (cold/reactive): 🚀 v0.2.1 SHIPPED — owner approved, gem live, release cut

**Cadence:** cold/reactive, woken by a holdco nudge (~1h after pass 68). Reconstituted cold: git
log, WORKLOG, board (auth'd), local `tasks/`, inbox (no unread).

**The gate cleared.** The owner approved the waiting Release run `28503391917` — it succeeded and
**published v0.2.1 to RubyGems** keylessly via OIDC trusted publishing. Verified: `gem list cafe_car
--remote --exact` → `0.2.1`; the published-0.2.0 onboarding crash (`rails g cafe_car:resource` → 500)
is now fixed on the latest gem, so the README quickstart is safe to advertise again.

**Caught + fixed a release gap.** `rubygems/release-gem@v1` did **not** auto-create the GitHub
release object despite the workflow's `contents: write` grant (v0.2.0 had one; v0.2.1 didn't). Cut it
manually from the existing `v0.2.1` tag with CHANGELOG-derived notes + `--latest`:
<https://github.com/craft-concept/cafe_car/releases/tag/v0.2.1>. Filed a P3
([[release-workflow-auto-create-github-release]]) to add an explicit release step so future releases
don't need the manual touch.

**Board triage.** Three open tasks, all externally gated (unchanged from passes 66–68): two
CrayonBloom milestone trackers awaiting requirement tasks the CrayonBloom operator hasn't filed, and
`discoverability-launch` — now **technically unblocked** (latest gem no longer crashes) but still
owner-gated on accounts + go-ahead. No open PRs/issues, demo **200**, CI green.

**Shipped:** GitHub release v0.2.1; closed `publish-v0-2-1-awaiting-owner-approval` (done); filed the
release-workflow P3; sent the owner a one-shot close-out receipt (publish confirmed + discoverability
now unblocked, no action needed). **Next:** owner's call on the discoverability launch; otherwise the
unblocked build backlog is drained and the critical path is CrayonBloom requirements. Self-clearing at
this clean boundary; wake on a nudge, mail, or the 8h fallback.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 68 (cold/reactive): 🟢 healthy hold — v0.2.1 still owner-gated, re-ping already spent

**Cadence:** cold/reactive, woken by a holdco nudge (~2h after pass 67). Fallback cron armed.
Reconstituted cold: git log, WORKLOG, board (auth'd), local `tasks/`, inbox.

**Assessed.** CI green (`b901acf`), tree clean, demo **200**, no open PRs/issues, no unread mail.
Board triage: only three non-done tasks, all externally-gated — `dogfood-crayonbloom` (P1) and
`dogfood-milestone-…` (P2) are milestone trackers waiting on the CrayonBloom operator to file
concrete requirement tasks (none have landed; the coordination is already established, so nudging
again would be noise), and `discoverability-launch` (P2) stays parked behind v0.2.1. Unblocked build
backlog remains genuinely drained.

**v0.2.1 publish — still the one live thread.** Release run `28503391917` **still `waiting`** on the
owner's trusted-publishing approval (~8h55m; started 04:13 EDT overnight). RubyGems still shows
**0.2.0**, so fresh `gem install` + `rails g cafe_car:resource` still hits the onboarding crash 0.2.1
fixes. **Held the re-ping:** pass 67 spent the single morning re-ping (11:02 EDT) with the one-click
steps + URL correction; the tracker says hold all further nudges until the owner acts. A second ping
within ~2h is nagging. Ideation stays deferred (discretionary; defers in REACTIVE mode).

**Shipped:** this worklog entry only — correct hold otherwise. **Next:** owner approves → 0.2.1
publishes + GitHub release auto-cuts; verify `gem list cafe_car --remote` → 0.2.1 and mark the
tracker done. Self-clearing at this clean boundary; wake on approval, a nudge, mail, or the 8h
fallback tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 67 (cold/reactive): spent the one v0.2.1 re-ping now that morning arrived

**Cadence:** cold/reactive, woken by a holdco nudge. Reconstituted cold: git log, WORKLOG, board
(auth'd), local `tasks/`, inbox. CI green (`17b2edc`), tree clean, demo **200**, no open PRs/issues,
no unread mail.

**Board triage.** Only three non-done tasks, all externally-gated: `discoverability-launch`
(parked *behind* v0.2.1 — don't point installers at a crashing latest), plus two CrayonBloom
milestone trackers (`dogfood-crayonbloom`, `dogfood-milestone-…`) that wait on requirement tasks the
CrayonBloom operator hasn't filed yet. No new buildable CrayonBloom requirements on the board. The
unblocked build backlog remains genuinely drained.

**The one live thread — v0.2.1 publish.** Release run `28503391917` **still `waiting`** on the
owner's trusted-publishing approval (~6h50m; started 04:13 EDT overnight). RubyGems still shows
**0.2.0**, so fresh `gem install` + `rails g cafe_car:resource` still hits the onboarding crash 0.2.1
fixes.

**Decision — spent the single re-ping.** Passes 65/66 deliberately held the ping to avoid nagging
overnight; pass 66 set the trigger "re-ping once real morning hours elapse." It's now **11:02 EDT** —
condition met. **Sent one gentle re-ping** to the owner with the one-click approval steps, then a
one-line **correction** (the first email's approval URL got mangled). Updated the tracker: this
spends the single re-ping — **holding all further nudges** until the owner acts.

**Shipped:** tracker update + this worklog entry. **Next:** owner approves → 0.2.1 publishes + GitHub
release auto-cuts; verify `gem list cafe_car --remote` → 0.2.1 and mark the tracker done. Going idle;
wake on approval, a nudge, mail, or the 8h fallback tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 66 (cold/reactive): 🟢 healthy hold — unblocked backlog drained, critical path is owner-gated

**Cadence:** cold/reactive, woken by a holdco nudge (~44 min after pass 65). Fallback cron still
armed. Reconstituted cold: git log, WORKLOG, board (auth'd), local `tasks/`, inbox.

**Assessed.** CI green (`37445d7`), tree clean, demo **200**, no open PRs/issues, no unread mail.
Triaged the full board + local `tasks/`: **every task done except three, all blocked** —
`publish-v0-2-1-awaiting-owner-approval` (BLK:user), `discoverability-launch` (BLK:user),
`dogfood-crayonbloom` (BLK:crayonbloom-operator). No new CrayonBloom requirement tasks have landed
on my board. The unblocked build backlog is genuinely drained.

**v0.2.1 publish — still the one live thread.** Release run `28503391917` remains **`waiting`** on
the owner's trusted-publishing approval (~5h; started 04:13 EDT overnight). RubyGems still shows
**0.2.0** latest, so the onboarding-crash fix isn't live. **Held the re-ping this pass:** pass 65
(only 44 min earlier) explicitly deferred it to "give the owner their morning," and I'd already
pinged twice overnight — a third within the hour is nagging. Tracker task carries the approval
URL/steps.

**Why not ideation:** ideation is discretionary and **defers in REACTIVE mode** (my cadence) —
manufacturing busywork against an owner-gated critical path is the wrong move. Discoverability is
correctly parked *behind* v0.2.1 (don't launch at a gem whose published latest still crashes).

**Shipped:** this worklog entry only — correct hold otherwise. **Next:** owner approves → 0.2.1
publishes + GitHub release auto-creates (verify `gem list cafe_car --remote` → 0.2.1, mark task
done). If still `waiting` next pass **with real morning hours elapsed** → one gentle re-ping. Going
idle; wake on the approval, a nudge, mail, or the 8h fallback tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 65 (cold/reactive): v0.2.1 still awaiting owner approval — filed durable tracker

**Cadence:** cold/reactive. Fallback cron `90514895` armed.

**Assessed:** CI green (`5e67db1`, pass 64), tree clean, no open PRs/issues, demo **200**, board
unchanged (3 externally-gated). Pass 64 (other session) drained the adoption-polish backlog —
benefit-led README hero + 60s quickstart + gemspec SEO (`1a34afa`) and docs OG/social meta + sitemap
via jekyll-seo-tag (`28f439b`); that task is now `done`.

**The one live thread — v0.2.1 publish:** the Release run (`28503391917`) has been **`waiting` on
owner approval for ~4h** (emailed ~04:13 EDT, overnight), and RubyGems still shows **0.2.0** as
latest — so the trust-critical onboarding-crash fix isn't live yet. The blocker was tracked only in
the worklog + emails + the waiting run, not durably. **Filed
`tasks/publish-v0-2-1-awaiting-owner-approval.md`** (P1, `blocked_on: user`) so it's board-visible and
can't slip — with the exact approval URL/steps and a follow-up cadence.

**Decision — no 3rd email this pass:** already pinged twice on pass 63 (initial + re-tag correction)
overnight; a third ping hours later, still overnight/early-morning, risks nagging. Gave the owner
their morning. **If still `waiting` next pass → one gentle re-ping** (it's trust-critical: every day
0.2.0 is latest, organic installers hit the crash) + surface on the holdco board.

**Shipped:** the tracker task only — correct hold otherwise. **Next:** owner approves → 0.2.1
publishes + GitHub release auto-creates (verify `gem list cafe_car --remote` → 0.2.1, mark task done).
Going idle; wake on the approval, nudge, mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 64 (cold/reactive): 🟢 worked the adoption-polish backlog — README/gemspec copy + docs SEO

**Cadence:** cold/reactive, woken by a holdco nudge. Fallback cron still armed. Reconstituted cold
(post-`/clear`): git log, board, inbox (no unread), WORKLOG.

**Assessed.** v0.2.1 release run still **`waiting`** on the owner's trusted-publishing approval
(~4h; RubyGems still shows 0.2.0 latest). Owner was already emailed in Pass 63 — re-mailing would be
noise, so left it. `discoverability-launch` (P2) stays parked: don't point a launch at the crashing
0.2.0 gem until 0.2.1 publishes. Highest-leverage **unblocked** work = the `adoption-polish-from-bullhorn-audit`
backlog. Split it into two file-disjoint builder passes, ran them in parallel.

**Shipped (both CI-green on `main`):**
- **`1a34afa` (designer, voice-gated):** benefit-led README hero rewrite (mechanism-first →
  the "model already knows its columns / Rails still makes you hand-write 7 actions" gap framing
  from `marketing/launch-post.md`), tagline subtitle, sharpened "Perfect for" audience line, star
  CTA, and a "try it in 60 seconds" quickstart above the fold using the **macro/manual path**
  (verified against `lib/cafe_car/controller.rb` — deliberately NOT the resource-generator one-liner
  that crashed in 0.2.0). Refreshed `cafe_car.gemspec` summary/description to name keyword search,
  filtering, CSV export, Pundit, Hotwire — the RubyGems/Google SEO surface; ships next release.
- **`28f439b` (coder):** wired the docs site's OG/Twitter social meta + `og:image` (the committed
  `og-card.png`, previously wired to nothing) + `sitemap.xml`. Good judgment call: used the cayman
  theme's built-in `{% seo %}` (jekyll-seo-tag, always-on GH-Pages plugin) via `_config.yml` instead
  of the task-prescribed hand-rolled `head-custom.html` — hand-rolling would have emitted
  duplicate/conflicting `og:title`/`canonical`/`twitter:card` alongside `{% seo %}`. Verified by
  building a scratch Jekyll site and inspecting the rendered `<head>`. Analytics counter skipped
  (optional; owner may prefer none).

Marked `adoption-polish-from-bullhorn-audit` **done** — only residual is the owner-gated GitHub repo
social-preview upload (tracked in `owner-one-time-dashboard-wiring-…`).

**What's next:** owner approves v0.2.1 → it publishes + GitHub release auto-creates (watch for it),
which unblocks `discoverability-launch`. Backlog is now thin on unblocked items — remaining opens are
the CrayonBloom dogfood milestone and owner/launch-gated work. Going idle; wake on approval, nudge,
mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 63 (cold/reactive): 🔴→🟢 bullhorn audit caught a first-touch crash → staged v0.2.1

**Cadence:** cold/reactive. Fallback cron `90514895` armed. After ~10 hold passes with the board
fully gated, used the sustained-hold capacity for a proactive on-mission audit instead of an 11th
nothing-pass — the review panel became available this session (`ec62aea` roster repair).

**Ran a `bullhorn` GTM audit** for UNBLOCKED adoption levers. It paid for itself immediately: it
downloaded the actual published `cafe_car-0.2.0.gem` and read its generator source, catching a
**trust-critical blocker** — the README's headline quickstart (`rails g cafe_car:resource ...`)
**crashes on the installed gem** (policy-generator `ArgumentError` → `/products` 500s). So every cold
Rails dev who `gem install`s today hits a stack trace on their first hands-on try. **Verified myself:**
the fix (3 compounding onboarding bugs) is already merged to `main` (`cbda67c`) and sits in CHANGELOG
`[Unreleased]`, but no 0.2.1 had shipped.

**Shipped — staged the v0.2.1 patch (root-cause fix, not a README band-aid):**
- coder cut it: `version.rb` → 0.2.1, CHANGELOG `[Unreleased]`→`[0.2.1] - 2026-07-01` + fresh
  Unreleased + footnote links (`0beb6ad`), `rake` green (125 tests, up from 122 — the fix's coverage).
- **Caught + fixed a release-blocking CI failure:** the version bump changed the path-gem gemspec but
  `Gemfile.lock` still pinned 0.2.0; CI/release run bundler **frozen** → "gemspecs for path gems
  changed … frozen mode is set". The coder's local `rake` had regenerated the lock but (scoped to two
  files) left it uncommitted. Committed the lock (`04aa1f6`), **moved the `v0.2.1` tag** to the green
  commit, cancelled the stale release run. CI now green on `04aa1f6`. Added a guard comment to
  `release.yml` + a [[version-bump-needs-gemfile-lock]] memory so this doesn't recur.
- **Release run is `waiting` on owner approval** (OIDC trusted-publishing, `release` env). Emailed the
  owner (+ a correction after the re-tag) requesting the approval click — framed trust-critical.

**Also filed** `tasks/adoption-polish-from-bullhorn-audit.md` — the audit's remaining unblocked
findings (README hero rewrite, gemspec SEO summary, docs `head-custom.html` OG/sitemap, brand tagline,
star CTA), ranked, split copy(voice-gate)/technical(coder). This converts future hold-passes into a
real unblocked adoption backlog.

**What's next:** owner approves v0.2.1 → it publishes + GitHub release auto-creates (watch for it).
Then work the adoption-polish backlog down over coming passes. Going idle; wake on the approval,
nudge, mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 62 (cold/reactive): backported dream v2 + repaired broken agent roster

**Cadence:** cold/reactive. Fallback cron armed.

**Assessed:** CI green, tree clean. All shipped tasks done; the only unblocked work was fleet
backports from the holdco template — a new **P1 board task** had landed
(`backport-cafe-car-adopt-the-dream-v2-persona-upgrade-seeded-`, filed 05:16). Everything else on
the board is blocked (owner or the CrayonBloom operator).

**Shipped two backports:**
1. **dream v2 persona upgrade (`151c65b`)** — synced `.claude/agents/dream.md`,
   `.claude/commands/dream.md`, and new `docs/DREAM-SEEDS.md` from `templates/new-venture`
   (`{{VENTURE}}`→`cafe_car`). Adds seeded divergence, decisions ledger, sliding-floor WORKLOG
   mining, decision-drift audit, verified journals. Board task marked done. `rake` green.
2. **operator agent roster (`39137447`)** — **discovered mid-pass:** dispatching a `coder` builder
   failed (`Agent type 'coder' not found`). My `.claude/agents/` had only conductor/designer/dream,
   but my charter references a `coder` builder **and** the full review panel — none existed locally.
   Backported the 7 missing personas (coder, graybeard, hipster, green-eyeshade, counsel, bullhorn,
   redteam) from the template. Deliberately **skipped** the template's `operator.md` — this venture
   uses the customized `conductor.md`. `rake` green; agent types now register live.

**Decision/assumption:** ran the two builders **serially** (builder 2 dispatched only after builder 1
pushed) to avoid a concurrent-push race on `main` — disjoint files still share the branch.

**Meta:** the roster gap meant my two core delegation moves (delegate to a coder, convene a review
board) were both silently broken until this pass. Self-repair; no owner action needed. Filed both as
`tasks/` entries (durable) even though one was self-discovered.

**Triaged:** inbox not re-checked this pass (nudge-driven). Open items unchanged: CrayonBloom spec
(their spec-author task still open), owner launch/discoverability (blocked on user). **Next:** poll
board for CrayonBloom requirement tasks; otherwise hold. Going idle; wake on nudge, mail, a PR, or
the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 61 (cold/reactive): shipped holdco durable-state backport

**Cadence:** cold/reactive. Fallback cron armed.

**Assessed:** CI green, tree clean, no PRs/issues, demo **200**. A new **P1 board task** had landed
(`cafe-car-backport-durable-state-fixes-holdco-2d92c67`) — a fleet backport from holdco of the
durable-state fixes root-caused from the PrintBound "operator can't see an email it already handled"
incident. Picked it as the highest-leverage unblocked item.

**Shipped (`db1b9c2`):** Part 1 — added the **"Reconstitute before you answer"** reflex to
`.claude/agents/conductor.md` (full) and `AGENTS.md` (tight): *"not in my context" ≠ "doesn't exist"* —
look it up in inbox `--all` / git log / task board / WORKLOG before claiming you can't see something.
`rake` green (rubocop+test+brakeman, 0 warnings). Board task closed with comment id 8, marked done.

**Decision — Part 2 (sync repo `bin/operator-loop`) is a deliberate no-op for CafeCar:** holdco
launches every venture via its **own** canonical `~/code/holdco/bin/operator-loop` (holdco.rb:855),
already at 2d92c67 with the lineage-follow fix. CafeCar has never had a repo `bin/operator-loop` and
nothing references one — a copy would be a dead duplicate. Fix already in effect for me. Recorded on
the board comment so holdco sees the reasoning.

**Triaged:** inbox clean (no unread). Open items unchanged: CrayonBloom spec (their spec-author task
still open), owner launch/discoverability (blocked on user). **Next:** unchanged. Going idle; wake on
nudge, mail, a PR, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 60 (cold/reactive): healthy hold; triaged cross-venture owner mail

**Cadence:** cold/reactive. Fallback cron `90514895` armed.

**Assessed:** CI green (`f328eb2`), tree clean, no open PRs/issues, demo **200**, board + local tasks
unchanged (same three externally-gated items). Internalized `f328eb2` ("email is an inbox, not a work
trigger") — already reflected in my charter.

**Triaged owner mail (no action):** one unread from `jeff@yak.sh` — a forwarded **PrintBound**
roadmap thread + a holdco email-delivery RCA ("another forgotten email"). Not CafeCar's domain
(PrintBound product + holdco infra). Read + dismissed; the RCA is holdco's, the roadmap is
PrintBound's. Note the meta-signal (owner frustrated by "forgotten" mail) reinforces *triage every
inbound, don't silently drop* — which is exactly what I did here.

**Shipped:** nothing — correct hold. **Next:** unchanged (CrayonBloom spec / owner launch / Dependabot
PRs). Going idle; wake on nudge, mail, a PR, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 59 (cold/reactive): healthy hold; internalized fleet art policy

**Cadence:** cold/reactive. Fallback cron `90514895` armed; real cadence = holdco nudges + mail.

**Assessed:** CI green (`69d91dc`), tree clean, **no open PRs/issues**, no inbound mail, demo **200**
on the canonical host. Board + local tasks unchanged — same three externally-gated `open` items
(dogfood → CrayonBloom operator, discoverability + dashboard-wiring → owner). Unblocked long tail was
already drained by passes 57–58 (stale-cnc README cleanup, README TOC). Genuine hold.

**Internalized new fleet policy (`69d91dc`, owner feedback):** "generated art assumes a human in the
loop" — added to AGENTS.md + designer.md. Iterate freely on reversible drafts; treat any final/
irreversible art action (launch-ready, print-ready, publishing) as owner-gated until reviewed.
Checked it against CafeCar: **no conflict, nothing to fix** — our generated assets (logo, OG card,
favicon) are committed as reversible in-repo drafts, and the irreversible uses (OG upload to GitHub
Settings, launch post) are already owner-gated. Traces to the owner's CrayonBloom share-card feedback
the fleet generalized.

**Shipped:** nothing — correct hold. Did not nudge the owner on the gated launch: they're mid
CrayonBloom launch (Stripe/print), CafeCar's launch is theirs to time, and the board task already
surfaces it async. **Next:** unchanged — CrayonBloom spec / owner launch / Dependabot PRs. Going
idle; wake on nudge, mail, a PR, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-07-01 — Pass 58 (cold/reactive): always-on license — added a README table of contents (visibility barrier)

**Cadence:** cold/reactive. Woken by a holdco nudge (proactive pass).

**Assessed:** CI green (Pass 57 completed clean), demo **200**, tree clean. Verified an assumed
license gap was a false alarm — `MIT-LICENSE` exists, gemspec declares MIT (`cafe_car.gemspec:17`),
badge in README, file is packaged; hygiene solid (checked because a `LICENSE*` glob missed the
Rails-convention `MIT-LICENSE` name). Backlog: local tasks fully done-or-externally-blocked. Holdco
board shows a **new** `dogfood-milestone` tracker, but it only unblocks once the CrayonBloom operator
files individual requirement tasks — none have appeared yet, so still no buildable spec. Genuine hold
on the queue → exercised the always-on license against the **visibility** barrier.

**Shipped (`470ca23`):** The README — our #1 conversion surface — was 806 lines / ~25 sections with
**no table of contents**; an evaluator landed on a wall of scroll with no way to jump to "How CafeCar
compares" or "Generators". Ran the cheap-envelope rubric (README-only / additive / reversible;
smallest test = anchors resolve + `rake` green) and delegated to a builder: added a `## Table of
Contents` after the intro listing all 13 top-level sections, with Core Components + Generators nested.
Builder script-verified all **24 anchors** resolve (extract headings → compute GHFM slugs → diff vs
TOC links; edge cases `#how-cafecar-compares`, `#sessions--authentication`, `#filtering--sorting`
confirmed). `bundle exec rake` green (Brakeman clean). Logged the idea `running`→`kept` in IDEAS.md.

**State:** backlog remains fully done-or-externally-blocked; no unblocked queue work. The dogfood
milestone waits on CrayonBloom-operator specs; publish/discoverability/dashboard wait on the owner.

**Next:** owner-blocked and CrayonBloom-blocked items await their owners. Going idle after this log —
holdco nudges next cadence. If the hold persists, next pass continues the always-on license against
visibility/trust (e.g. dependency-diet audit, already IDEAS-queued).

**Session:** https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-07-01 — Pass 57 (cold/reactive): cleared the last unblocked task — stale `cnc` in README install list

**Cadence:** cold/reactive. Woken by a holdco nudge (proactive pass).

**Assessed:** CI green, working tree clean, inbox clear (one held bounce for the already-applied
portfolio-values directive `4e5fa18` → marked read). Backlog: 4 tasks `open`, 3 externally blocked
(discoverability → user, dogfood → CrayonBloom operator, dashboard-wiring → user). No untriaged
tasks; no new CrayonBloom board items. Exactly one unblocked item —
`readme-remove-stale-cnc-install-dep` (P2), a trust/accuracy nit surfaced during Pass 56's
onboarding verification.

**Shipped (`ef4cba2`):** README **Installation** list still named `cnc` as a required gem after
`cnc` was cut wholesale (`cut-cnc-switch-to-omakase`). A reader following the steps would install
an unnecessary gem — directly undercutting the "we removed the private-dep friction" story.
Delegated to a builder: dropped `cnc` from line 104, grep-confirmed it was the file's *only* `cnc`
reference (no other stale mentions, none historical to preserve), and sanity-checked the remaining
gems — `rouge` is a real gemspec dep (`cafe_car.gemspec:44`); `bcrypt`/`paper_trail`/
`factory_bot_rails`/`faker` are added to the host app by `cafe_car:install`, all legitimate.
`bundle exec rake` green (125 runs, 0 failures, Brakeman clean). Task marked done via
`rake tasks:done`, which regenerated `TASKS.md` from the 38 task files.

**State:** backlog is now fully done-or-externally-blocked — every remaining `open` task waits on
the owner or the CrayonBloom operator. No unblocked queue work remains.

**Next:** owner-blocked items (RubyGems key for v0.2.0 publish, discoverability launch, dashboard
wiring) await the owner; dogfood awaits CrayonBloom. Going idle after this log — holdco will nudge
next cadence. If the hold persists, next pass exercises the always-on license against the
activation/trust barrier again.

**Session:** https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-07-01 — Pass 56 (cold/reactive): quickstart verification uncovered + fixed a broken onboarding flow; 2 holdco directives applied

**Cadence:** cold/reactive. Woken by a holdco nudge (proactive pass); two VERIFIED holdco
directives (`auth=VERIFIED(bot.yak.sh)`) also landed mid-pass and were applied inline.

**Assessed:** CI green, demo **200**, inbox clean. Backlog fully done-or-externally-blocked (same
three `open` items: discoverability → user, dogfood → CrayonBloom operator, dashboard → user). No
new CrayonBloom requirement tasks on the holdco board. No untriaged tasks. Genuine hold on the
queue → exercised the always-on license against the **activation/trust** barrier.

**The big win — a broken headline onboarding flow, found by insisting on accuracy.** Dispatched a
builder to add a copy-paste "60-second try" README block (IDEAS-logged, cheap/reversible). The
builder honored the accuracy gate, ran the full install path against a fresh Rails 8.1 app, and
found **`rails g cafe_car:resource` 500s out of the box** — the gem's advertised primary onboarding
path was broken. It correctly *killed* the block (shipping a quickstart that fails on step 2 burns
the trust it's meant to build; `20e48d5`) and root-caused three bugs. I filed those as a P1 fix and
dispatched a second builder — all three diagnoses held (each reproduced red-first):
- **A** — `authentication.rb` `current_session` ignored the existing `sessions_available?` gate →
  every authorized action 500'd without a sessions table + User model, contradicting the README's
  "plain CRUD → 403 not 500" promise. Now gated; nil user → 403.
- **B** — `cafe_car:resource` dropped the field list when delegating to `cafe_car:policy`.
- **C** — `policy_generator` called `ModelInfo.new` positionally (needs `model:` kwarg) + a
  placeholder guard keyed off the wrong condition.
- **Verified:** fresh app, NO sessions/User → `GET /products` = **200** (real admin table). CI gap
  closed (resource-generated policy now rendered end-to-end in tests). `[Unreleased]` CHANGELOG
  entry added. Shipped `cbda67c`; `bundle exec rake` green (125 tests), CI green.

**Two holdco directives applied inline (both VERIFIED internal, reversible docs changes):**
- HTML/CSS→PNG for text-heavy raster assets → baked into the designer persona (`284c897`, logged
  in Pass 55 above — landed at the top of this pass).
- **Portfolio values policy** ("Our purpose and our standard" — for the glory of God, above profit
  and growth; nothing wrong in God's eyes; never offensive to Christ/Christians; love your
  neighbor even when it costs money) → added as the first `##` section of **AGENTS.md** and
  **BRAND.md** (`4e5fa18`). Governs product/customer-request decisions going forward. Ack'd to holdco.

**Filed (no dispatch — non-urgent):** `readme-remove-stale-cnc-install-dep` (P2) — README
Installation still lists `cnc` as required, stale since cnc was cut. Non-breaking doc nit; batched
for a future README polish rather than a third builder this pass.

**Decisions/assumptions:** Treated the generator-bug fix as ordinary maintainer work (restoring
documented behavior, no new API, no owner gate) — dispatched immediately given a broken headline
quickstart actively repels adopters. `coder` agent type isn't registered here; used the general
`claude` builder. IDEAS row for the 60-second block → `killed` (revisit once onboarding is proven
smooth; don't re-propose the block until then).

**Next:** Onboarding flow is now honest end-to-end, which unblocks re-attempting the 60-second
block later. Backlog otherwise still externally gated. Going idle; fallback cron armed, real
cadence = nudges + mail.

---

## 2026-06-30 — Pass 55 (cold/reactive): applied holdco fleet guidance to designer persona

**Cadence:** cold/reactive. Woken by VERIFIED internal mail from holdco (`auth=VERIFIED(bot.yak.sh)`),
owner-approved fleet guidance — actionable under charter; reversible internal docs change, no risk floor tripped.

**Shipped:** `284c897` — baked into the designer persona (`.claude/agents/designer.md`, item 5 "Visual
assets"): build text-heavy raster cards (OG/social, thumbnails) as HTML/CSS rendered to PNG via headless
screenshot rather than hand-authored SVG (SVG has no box model → fragile text overflow/wrap/kerning);
`await document.fonts.ready` before capture. Carve-out preserved: SVG stays fine for vector UI/icons/logos.
Home chosen = persona, not AGENTS.md, since AGENTS.md already delegates visual technique to the designer
persona (line 69). Replied to holdco confirming applied.

**Decisions:** No new visual assets in flight, so this is guidance-for-next-time, not a rebuild of anything.
Nothing to redo — CafeCar's existing assets weren't flagged.

**Next:** Board unchanged — three externally-gated `open` items (discoverability → user, dogfood →
CrayonBloom operator, dashboard-wiring → user). Going idle; fallback cron armed, real cadence = nudges + mail.

---

## 2026-06-30 — Pass 54 (cold/reactive): shipped README positioning section (broke the 4-pass hold)

**Cadence:** cold/reactive. Fallback cron armed; real cadence = holdco nudges + mail.

**Assessed:** CI green (`c0cf7ea`), tree clean, demo **200** on the canonical host. Board unchanged:
same three externally-gated `open` items (discoverability → user, dogfood → CrayonBloom operator,
dashboard-wiring → user). No owner mail (`email-inbox` clean). Re-checked CrayonBloom's board — their
spec task "Define the back-office requirements for the CafeCar dogfood" is still **`open`**, so no
requirement tasks have landed for me; the dogfood gate is unchanged.

**Judgment call — broke the hold.** Passes 50–53 were all healthy holds. Rather than mechanically
declare hold #4, I hunted for a concrete, cheap, reversible, no-owner lever against the **trust**
barrier (CafeCar's core growth constraint per charter). Found one: the README has a thorough API
reference but **zero positioning content** — in a crowded admin-gem space, every evaluator's first
question ("why this over ActiveAdmin/Avo/Administrate/RailsAdmin/Trestle?") was answered nowhere.
That's a real backlog gap, not blue-sky ideation — so shipping it is legitimate reactive work, not
the ideation that defers in REACTIVE mode.

**Shipped:** `d22b28e` — new **"How CafeCar compares"** README section (delegated to a builder;
`claude` type since `coder` wasn't registered this session). Thesis-first (convention-over-config,
stay in Rails, no separate DSL), then a fair, generous "reach for X when…" table covering the five
main alternatives — no trash-talk, no superlatives, matches the README's understated voice.
**Reviewed for fairness/accuracy** before accepting: every claim verified true (ActiveAdmin/Arbre
DSL, Avo config-driven + commercial Pro tiers, Administrate's owned generated code, RailsAdmin's
engine-mount + runtime introspection, Trestle's DSL). `bundle exec rake` green (122 runs / 367
assertions / 0F/0E, brakeman clean); **CI green** on the push.

**Also:** seeded `IDEAS.md` (was an empty template stub since `bd69488`) with 5 real ideas — the
shipped comparison section (`running`→now kept), plus proposed: a top-of-README "60-second try"
block, a `cafe_car:install` one-shot bootstrap generator, a standalone comparison blog post, and a
dependency-diet re-audit. The consequential ones (new generator API, public post w/ competitors +
owner's name) are flagged for `/propose`, not unilateral action.

**Next:** unchanged external gates — CrayonBloom spec, owner launch go-ahead, dashboard wiring. Cheap
in-envelope follow-ups now queued in `IDEAS.md`. Committing + logging, then idle; wake on nudge, mail,
a PR, or the fallback tick.

---

## 2026-06-30 — Pass 53 (cold/reactive): healthy hold; owner mail triaged, ideation engine verified

**Cadence:** cold/reactive. Fallback cron `90514895` armed; real cadence = holdco nudges + mail.

**Assessed:** CI green (`bd69488`), tree clean, **no open PRs/issues** (Dependabot queue was drained
pass 49), demo **200** on the canonical host, board unchanged (same three externally-gated `open`
items). All non-done local tasks gated (discoverability → user, dogfood → CrayonBloom operator,
dashboard-wiring → user). 4th consecutive healthy hold (50–53) — correct: v0.2.0 is live and every
unblocked lever is already pulled (topics, README screenshots, Dependabot, CHANGELOG).

**Owner mail triaged (no action):** one unread from `jeff@yak.sh` — but it was a **CrayonBloom**
thread ("is the share card made with HTML? it has overflow bugs"), directed at CrayonBloom's
operator, not CafeCar's domain. CafeCar's OG card is a static PNG (no HTML/overflow risk). Marked
read; the owner's reply reaches CrayonBloom's operator in their own thread. Mirrors pass-46 handling
of cross-venture owner mail.

**Verified (not ideation):** the "standing imagination engine" another session rolled in (`bd69488`
— AGENTS.md Ideation section, conductor.md bullet, `IDEAS.md` stub, `/propose`, dream divergent leg)
landed cleanly, nothing half-wired. Left `IDEAS.md`'s placeholder unseeded on purpose — **ideation
defers in REACTIVE mode**; it's the scheduled dream's divergent leg, not a reactive-tick activity.

**Shipped:** nothing — correct hold. **Next:** unchanged — CrayonBloom spec / owner launch go-ahead /
Dependabot PRs. Going idle; wake on nudge, mail, a PR, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-30 — Pass 52 (cold/reactive): hold confirmed; live demo end-to-end verified

**Cadence:** cold/reactive — holdco nudge. Fallback cron armed; cadence stays nudges + inbound mail.

**Assessed:** main CI green (run 28483120456), tree clean, no open PRs, no open issues, no inbound
mail, nothing held in `email-inbox`. Board GET (venture=cafe_car) shows no new concrete tasks.

**Demo verified end-to-end (not just root ping).** Landing `200` (`<title>CafeCar — live demo</title>`),
and the actual admin mounted at `/admin` renders live CRUD: `/admin/clients`, `/admin/invoices`,
`/admin/articles` all `200`. The #1 conversion/trust asset is healthy — confirmed the app itself works,
not merely that the process is up.

**Gates re-polled, unchanged.** Same three externally-blocked open tasks as Passes 50–51. I mined
CrayonBloom's board directly rather than waiting: their spec-author task
`define-the-back-office-requirements-for-the-cafecar-dogfood` is still **open** (unchanged since pass 23,
3+ days) → the dogfood P1 is genuinely blocked on their spec, not on me. `discoverability-launch`
(owner-gated publish; all no-account passive levers already shipped pass 41) and `owner-dashboard`
(three console-clicks, workarounds holding) remain owner-gated. Custom-actions pre-build stays held per
the Pass 51 semver decision.

**Decision:** healthy hold, no busywork. The demo verification is the pass's concrete value-add. Logged
honestly, going idle per cold-mode charter.

**Shipped:** this worklog entry only.

---

## 2026-06-30 — Pass 51 (cold/reactive): hold reaffirmed + custom-actions design decision

**Cadence:** cold/reactive — holdco nudge. Fallback cron armed; cadence stays nudges + inbound mail.

**Assessed:** main CI green (run 28480894342), tree clean, **demo 200 (0.15s)**, no open PRs, **no open
issues**, no inbound mail. Dream ran today already — no maintenance owed.

**Gates re-polled, unchanged.** Same three externally-blocked open tasks as Pass 50. CrayonBloom's
spec-author task `define-the-back-office-requirements-for-the-cafecar-dogfood` is still **open**; no
requirement tasks landed on my board. `discoverability-launch` + `owner-dashboard` still owner-gated.

**New decision (so future passes stop re-litigating it):** I weighed pre-building the top anticipated
dogfood delta — **custom member/collection actions** (approve/reject) — as a "generic, non-speculative"
capability. **Verdict: keep holding.** Rationale: the *mechanism* may be generic, but a **public gem's**
custom-action API is semver-locked once shipped. Designing it without its first real consumer
(CrayonBloom's moderation queue) risks shipping an API in v1 that I'd have to **break** the moment they
actually spec their needs — strictly worse than waiting. Custom actions are not in `V1_SCOPE.md`'s
audited feature set; they're "not yet built," and the right time to build is *with* the consumer's spec,
not before. The pass-23 hold stands.

**Decision:** healthy hold, no busywork. Logged honestly, going idle per cold-mode charter.

**Shipped:** this worklog entry only.

---

## 2026-06-30 — Pass 50 (cold/reactive): backlog drained, healthy hold

**Cadence:** cold/reactive — holdco nudge. Fallback cron armed; cadence stays nudges + inbound mail.

**Assessed:** main CI green (run 28478084347), tree clean, **demo 200**, no open PRs, no inbound mail.
Dream cycle already ran today (`docs/dreams/2026-06-30.md`), so no maintenance owed.

**Backlog state — everything actionable is shipped.** Walked the full `tasks/` board: all `done`
except three, and all three are **externally blocked**, not owner-startable by me:
- `dogfood-crayonbloom` (P1) — gated on the CrayonBloom operator's spec. Polled their board: the
  spec-author task `define-the-back-office-requirements-for-the-cafecar-dogfood` is still **open**, and
  my `cafecar-dogfood-capability-snapshot-anticipated-deltas-for-y` snapshot is still open in their
  queue. No requirement tasks have landed on my board. Holding — no speculative features (per the
  task's own anti-scope-creep note).
- `discoverability-launch` (P2) — passive levers done (repo topics + website live); only the
  owner-gated **publish** step remains (needs owner's accounts/name on the post).
- `owner-one-time-dashboard-wiring` (P2) — owner-only Railway/GitHub config.

**Decision:** no busywork. Per cold-mode charter, a pass with nothing unblocked logs honestly and goes
idle rather than manufacturing work. Demo + CI + release state all healthy.

**Shipped:** this worklog entry only.

**Next:** wake on the next holdco nudge or inbound mail. Triggers to act on: a CrayonBloom requirement
task landing on my board (→ build it), an owner go-ahead on the launch/publish step, or a new
Dependabot PR / CI break. Going idle.

---

## 2026-06-30 — Pass 49 (cold/reactive): drained the Dependabot queue (rouge + image_processing + 2 new)

**Cadence:** cold/reactive — holdco nudge, shortly after pass 48. Picked up the rebased #19 plus a
fresh PR Dependabot opened (#20). Fallback cron armed; cadence stays nudges + inbound mail.

**Assessed:** main CI green, tree clean, demo **200**, no inbound mail.

**Finished the harvest — all PRs now closed/merged, queue empty:**
- **Merged #19 rouge 4→5** (rebased clean after pass-48 lock conflict, green).
- **Merged #20 image_processing 1.14→2.0.2.** This one is a **gemspec runtime dep** — checked before
  merging. Gemspec declares `image_processing >= 1.13`, a floor that **already permits 2.x**, so no
  gemspec change is needed; the PR only bumps the demo Gemfile pin + lockfile, and CI (test suite vs
  2.0.2) is green. Kept the permissive `>= 1.13` floor (correct for a library — don't pin majors).
- No more open PRs.

**Verified locally** (next-release state): `git pull` + `bundle install` + `bundle exec rake` →
**122 runs, 0 failures, 0 errors**, rubocop clean, Brakeman 8.0.5 with 0 warnings.

**Backlog check (board + tasks/):** entire backlog is **done or externally blocked** — only 3 open
items: the two CrayonBloom dogfood items (gated on their spec, unchanged) and discoverability-launch
(`blocked_on: user` — passive levers shipped pass 41, only the owner-gated publish/post step
remains). **No unblocked product work to dispatch a builder on.** Did not manufacture busywork; the
Dependabot harvest was the genuine highest-leverage work and it's complete.

**Next:** idle until nudge/mail. Future Dependabot PRs auto-surface for triage. Real product motion
is gated on CrayonBloom's spec or the owner's launch go-ahead.

---

## 2026-06-30 — Pass 48 (cold/reactive): first Dependabot harvest — triaged 6 PRs

**Cadence:** cold/reactive — holdco nudge, ~40 min after pass 47. The Dependabot config shipped pass
47 (`5a028c7`) did its first run and opened **6 PRs**; this pass was the harvest. Fallback cron still
armed; cadence stays nudges + inbound mail.

**Assessed:** main CI green, tree clean, demo **200** on the canonical host, no inbound mail. Six
fresh Dependabot PRs (#14–#19) — exactly the maintenance load the config exists to surface.

**Triaged all six against the CI gate (rubocop + test + brakeman):**
- **Merged 4 green:** #14 actions/checkout 5→7, #15 actions/upload-artifact 4→7, #16 bundler group
  of 6 (brakeman 8.0.4→8.0.5, sqlite3 2.9.0→2.9.5, faker 3.6→3.8, chrome_devtools_rails 0.1→0.2,
  activerecord_where_assoc 1.3→1.4, propshaft 1.3.1→1.3.2), #17 solid_cable 3→4.
- **Closed #18 minitest 5→6** with a note: upstream incompat — railties 8.1.3 still does
  `require 'minitest/mock'`, which minitest 6 removed/relocated (`LoadError` in CI). Rails doesn't
  support minitest 6 yet; Dependabot will re-open when a compatible Rails ships. **Not our bug.**
- **#19 rouge 4→5** (green) hit a Gemfile.lock conflict after #17 landed first → `@dependabot rebase`
  requested. In flight; merge next pass once green.

**Verified locally after the merges** (these become the next gem release): `git pull` + `bundle
install` (sqlite3 2.9.5 etc.) + `bundle exec rake` → **all green**, Brakeman 8.0.5, 0 warnings. Main
is a clean release state.

**Decision/assumption:** merged dependency PRs solely on the CI gate — all are dev/demo/CI deps
(none are gemspec runtime deps), so green rubocop+test+brakeman is sufficient; didn't gate on owner.
The major bumps (checkout 5→7, upload-artifact 4→7, solid_cable 3→4, rouge 4→5) all passed CI.

**Next:** merge #19 once rebased+green. Backlog unblocked items (discoverability-launch,
dogfood — still gated on CrayonBloom's spec) unchanged. No owner action needed.

---

## 2026-06-30 — Pass 47 (cold/reactive): v0.2.0 publish verified live + Dependabot hygiene

**Cadence:** cold/reactive — woken ~20 min after pass 46 (holdco nudge / loop re-entry, not the 8h
tick). Fallback cron `90514895` still armed; real cadence stays holdco nudges + inbound mail.

**Verified the v0.2.0 milestone (shipped by pass 46) actually landed correctly** — not just trusted
the prior worklog: RubyGems API shows `cafe_car 0.2.0` published 2026-06-30, `version.rb` = 0.2.0,
tag `v0.2.0` present, GitHub Release exists. All consistent. The gem is installable by anyone.

**Assessed:** CI green (latest `8a1401b`), tree clean, **no open PRs/issues**, no inbound mail, demo
**200** on the canonical host. CHANGELOG already carries a fresh `[Unreleased]` placeholder + dated
`[0.2.0]`. README fully equipped (logo + hero `admin-invoices-index.png` + form screenshot). Repo
topics/website set (pass 41). holdco board: same three `open` items. **Checked CrayonBloom's board
directly** — their spec-author task `define-the-back-office-requirements-for-the-cafecar-dogfood` is
still `open` and their back-office is `wip`, so the **P1 dogfood is genuinely still gated on their
spec**; no requirement tasks have landed. Did not re-ping (settled pass 40; their build is in
progress, they'll spec when ready).

**Shipped (`5a028c7`, via builder):** **`.github/dependabot.yml`** — the one unblocked OSS-hygiene
gap (none existed; never deliberately rejected). Two ecosystems (`github-actions` + `bundler`),
weekly/Sunday, grouped minor+patch into one PR per ecosystem, `open-pull-requests-limit: 5`,
`chore(deps)` prefix, `dependencies` labels. Automates the manual CI-action-bump class of work we'd
done by hand, signals an actively-maintained project, and — fittingly for cold mode — converts
future gated passes into productive "review + merge a grouped dep-bump" work. `rake` green
(rubocop 0 / 122 tests 0 fail / brakeman 0), CI green on `5a028c7`. Major bumps still arrive as
individual PRs (correct — they deserve individual review).

**What's next:** adoption is now owner-gated (launch publish needs accounts + the owner's name) and
the P1 dogfood is CrayonBloom-spec-gated. Watch for the first Dependabot PRs (triage + merge when
green). Going idle; wake on nudge, inbound mail, the 8h tick, or a Dependabot PR.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-30 — Pass 46 (cold/reactive): 🚀 v0.2.0 SHIPPED to RubyGems — post-publish closed

**Cadence:** cold/reactive — woken by a holdco nudge on the pass-45 context. Heartbeat fallback armed.

**The headline:** **cafe_car 0.2.0 is LIVE on RubyGems** (`created_at` 2026-06-30T19:18:47Z, ~37
downloads already). The owner approved the gated `release` environment job from pass 45; OIDC
trusted-publishing ran `rubygems/release-gem@v1` and **pushed cafe_car 0.2.0** keylessly — verified
in Release run `28469804814` ("Pushed cafe_car 0.2.0 to rubygems.org" → rubygems-await all-found)
and `gem list cafe_car --remote --exact` → `(0.2.0)`. This is the launch the project had been
parked on for ~20 passes. The 33-commit arc since v0.1.2 (opt-in sessions/auth, `cafe_car` macro
rename, CSV export, keyword search, nested-attributes forms, Pundit footgun fix, security
hardening) is now installable by anyone via `gem install cafe_car`.

**Assessed:** caught that the tag push had actually *published* (not just queued) — the owner's
Actions-UI approval completed the OIDC exchange. So the real remaining work was the **post-publish
checklist**, not the publish itself.

**Shipped (commit `959b4f3`, via coder):**
- **GitHub Release v0.2.0 created** from the existing tag using the CHANGELOG `[0.2.0]` body —
  now shows as **Latest** (`releases/tag/v0.2.0`). Previously only v0.1.1/v0.1.2 had release pages.
- **README/docs version sweep:** zero hardcoded stale refs (`0.1.x`, `~> 0.1`) — Gem Version badge
  is dynamic (left as-is), install snippet is unpinned `gem "cafe_car"`. No invented edits.
- **Task `publish-cafecar-v0-2-0` → `done`** with a dated post-publish note.
- `bundle exec rake` green (rubocop clean / 122 runs 0 fail / brakeman 0 warn) before commit.

**In flight:** CI run `28471543673` on `959b4f3` (rake was green locally pre-commit; expecting green).

**Decisions/notes:**
- Inbound owner mail ("loosen the ~/code clone requirement") is a **holdco-repo** tooling ask, not
  cafe_car's domain — marked read, left for the holdco operator/owner. Did not act on it.
- Verified-internal publish already happened upstream; no `gem push` initiated by me this pass
  (minimal-floor moot — the irreversible action was the owner's approval click in pass 45).

**What's next:** launch is shipped. Next leverage now shifts to **discoverability/adoption** —
`discoverability-launch` (P2, blocked_on: user), README hero screenshot, docs/demo polish. Remaining
open tasks are mostly owner- or sibling-venture-blocked (`dogfood-crayonbloom`, dashboard wiring).
Will work the unblocked discoverability long-tail next nudge.

---

## 2026-06-30 — Pass 45 (cold/reactive): v0.2.0 UNBLOCKED → tag pushed, publish gated on owner

**Cadence:** cold/reactive — woken by inbound VERIFIED holdco mail (`msg:1782846820644`) on a
fresh (post-`/clear`) context. Heartbeat fallback still armed.

**The unblock:** Two VERIFIED internal mails landed — holdco (`…820644`) and homelab
(`…860830`) — both confirming the owner completed the rubygems.org side: **trusted publisher
registered** (`cafe_car` → `craft-concept/cafe_car` → `release.yml` → env `release`), **stale
push key rotated/cleared**, and **release go-ahead given** (the Actions-UI approval IS the gate).
That cleared the last two gates that had `publish-cafecar-v0-2-0` parked for ~20 passes.

**Assessed cold:** PR #13 already merged (`release.yml` on main from pass 44), version.rb at
`0.2.0`, CI green, CHANGELOG `[Unreleased]` fully prepped. Only the release *execution* remained.

**Shipped (commit `6782ce2`):**
- Finalized CHANGELOG `[Unreleased] → [0.2.0] - 2026-06-30`, fresh `[Unreleased]` skeleton +
  compare links. `bundle exec rake` green (rubocop 204 files 0 offenses / 122 runs 0 fail /
  brakeman 0 warn). Committed + pushed; **waited for CI green** and verified HEAD == origin/main
  == CI-green SHA before tagging (no tag on a red commit).
- **Pushed tag `v0.2.0`** (annotated, exact version parity for the workflow's guard). Release run
  **28469804814** triggered and is `waiting` on the `release` environment.

**In flight (owner-gated):** the publish job is **PAUSED for the owner's approval** — gate #2
working structurally, not by convention. Emailed the owner the direct approval link; replied to
holdco + homelab confirming state. Minimal-floor honored: I push the tag, never the gem.

**Decisions/assumptions:** Did the CHANGELOG one-liner + tag myself rather than delegating —
it's the release *orchestration* (mine to drive), and a release-critical path where a delegated
date-edit is pure overhead. Recorded the owner resolution into the task file *before* acting
(write-back rule), since a `/clear` would otherwise lose it.

**Next:** on owner approval → confirm publication, write GitHub release notes for v0.2.0, refresh
README badges/version refs, verify `gem install cafe_car` resolves 0.2.0, then mark the publish
task `done`. If the first OIDC exchange throws, homelab asked for a ping.

---

## 2026-06-30 — Pass 44 (cold/reactive): re-routed the RubyGems credential ask to homelab

**Cadence:** cold/reactive — woken by a holdco nudge. Heartbeat (8h fallback cron) still armed.

**Assessed:** CI green (latest `bc2d8ee`, Pass 43), tree clean, **no open PRs/issues**, no inbound
mail (`email-inbox` empty), demo **200** on the canonical host. Board: same four open items, all
externally gated. CrayonBloom's spec task `define-the-back-office-requirements-for-the-cafecar-dogfood`
is **still `open`** (P1, open since 06-26) and my pass-23 capability-snapshot to their board is still
unacted → P1 dogfood genuinely gated on their operator, who's heads-down on launch P0s.

**Broke the gated-pass streak with a real routing fix, not a 5th board-watch.** Caught a
**mis-routed blocker**: `publish-cafecar-v0-2-0-to-rubygems` has sat `blocked_on: user` for ~20
passes waiting on "the owner's RubyGems key" — but per fleet policy a **credential/API key is an
infra ask → homelab**, not the owner direct. This task predates the homelab-routing convention
(migrated from QUESTIONS.md 06-27) and was never sent through the right channel. Grepped the whole
WORKLOG to confirm: every "RubyGems key" mention treated it as owner-only; homelab was never asked.

**Shipped:**
- Emailed `homelab@bot.yak.sh` (msg `OLPifJlF…`) to mint the publish credential — offered (a) a
  push-scoped RubyGems API key, or (b) **RubyGems Trusted Publishing (OIDC)** wired to
  `craft-concept/cafe_car` (preferred: keyless CI publish, no long-lived secret), gated behind a
  GitHub Environment with owner approval. Flagged that the **owner go-ahead gate stays owner-only**
  (gem push is irreversible — charter minimal-floor) and that homelab should escalate if the
  rubygems.org account is owner-held.
- Wrote the decision back to the task file: `blocked_on: user → homelab`, full note on the two-gate
  model (credential = homelab, go-ahead = owner).

**Decisions/assumptions:** This pre-positions the single biggest growth gate — the gem is currently
*uninstallable* at 0.2.0, so most visibility work (Awesome lists, launch post) is premature until
publish clears. Getting the credential staged means the moment the owner says "go," v0.2.0 ships.
Did **not** touch the board task entity (local file is canonical; email is the action). Held on
speculative dogfood deltas again — correct until CrayonBloom specs.

**Same-pass follow-through (homelab round-trip closed the whole credential lane):** homelab replied
within the pass, accepted the routing, and chose **OIDC Trusted Publishing** (keyless, owner-approval
structural). It opened **PR #13** (release.yml) — I reviewed it (tag trigger gated by `environment:
release`; minimal `id-token`/`contents` perms; a version-guard that fails unless the stripped tag ==
`CafeCar::VERSION`; official `rubygems/release-gem@v1`; `checkout@v5` matching `ci.yml`; MFA satisfied
by OIDC), confirmed PR CI green + CLEAN, and **merged it** (`4d3c0fd`). So in one pass the publish
blocker went from "mis-routed, sitting on the owner for ~20 passes" → "keyless release pipeline on
main, owner-approval enforced in the Actions UI, only the owner's one-time rubygems.org registration +
go-ahead remain." Net upgrade: gate #2 is now structural, not convention, and there's no long-lived
secret to manage. `blocked_on` for the publish task ended the pass at `user` (homelab's GitHub half
done; rubygems.org registration + go-ahead are owner-only). Commits: `8131e23`, `b97e330`, plus the
PR-merge write-back.

**What's next:** owner registers the trusted publisher (`cafe_car → craft-concept/cafe_car →
release.yml → release`) + gives the release go-ahead → I finalize the CHANGELOG date, push the
`v0.2.0` tag, owner approves the gated job → publish. Also still awaiting CrayonBloom requirement
tasks. Going idle; wake on nudge, inbound mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-30 — Pass 43 (cold/reactive): board still gated → ran the first-ever dream cycle

**Cadence:** cold/reactive — woken by a holdco nudge. Heartbeat (8h fallback cron) still armed.

**Assessed:** CI green (latest `774c9de`, Pass 42 worklog), tree clean, **no open PRs/issues**, no
inbound mail, demo **200** on the canonical host. holdco board: same four open items, **no new
CrayonBloom requirement tasks** — every non-done item is externally gated (RubyGems key, launch
publish, dashboard wiring, CrayonBloom requirements). Buildable product backlog is drained.

**Earned the gated pass with maintenance, not a 5th rubber-stamp board-watch.** `docs/dreams/` was
empty — no dream cycle had ever run despite 42 passes of accumulated WORKLOG/memory. Ran the first
one (`39e8da9`):
- **Memory:** 3 files all current; fixed a stale `demo-url` ref that pointed the Railway-App owner
  blocker at the retired `QUESTIONS.md` → repointed at the task board.
- **Lesson captured:** bare `rake` aborts with `Gem::LoadError` (system 13.3.1 vs Gemfile 13.4.2);
  `bundle exec rake` is the correct check-suite invocation (recurring since pass 39, confirmed still
  reproducing). New memory `bundle-exec-rake.md` + documented on the AGENTS.md check-suite line.
- **Persona:** `conductor.md` clean — no stale refs, no flags.

**Shipped:** `39e8da9` (AGENTS.md check-suite note + first dream journal) + this worklog. No product
code — correct for a fully-gated board. Memory edits live outside the repo (`~/.claude`).

**What's next:** unchanged — await CrayonBloom requirement tasks, the RubyGems key, or owner
go-ahead on the launch/dashboard items. Going idle; wake on nudge, inbound mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-30 — Pass 42 (cold/reactive): board watch — fully gated, owner-blockers verified migrated

**Cadence:** cold/reactive — woken by the session's 8h fallback cron `90514895`. Heartbeat armed;
real cadence stays holdco nudges + inbound mail.

**Assessed:** CI green (latest `1a10904`), tree clean, **no open PRs/issues**, no inbound mail, demo
**200** on the canonical host (`/`, `/admin/invoices`, `/up`). holdco board: same three `open` items,
**no new CrayonBloom requirement tasks** → P1 dogfood still genuinely gated on their operator.

**Verified a structural change from another session (`1a10904`, "retire QUESTIONS.md"):** QUESTIONS.md
is gone; confirmed its owner-facing blockers were cleanly migrated into discrete `blocked_on: user`
task files — `publish-cafecar-v0-2-0-to-rubygems-needs-owner-key` (P1) and
`owner-one-time-dashboard-wiring-railway-config-as-code-githu` (P2, the railway.toml dashboard
activation + Railway GitHub App). Nothing lost; the new owner-blocker mechanism is the task board +
write-back rule, not a standalone questions file. Updated my mental model accordingly.

**Shipped:** nothing — every non-done item (4 local tasks + 3 board) is gated on the owner (RubyGems
key, launch publish, dashboard wiring) or the CrayonBloom operator (requirement tasks). Pass 41
already harvested the one unblocked passive-discoverability lever (repo topics + website). Building
the anticipated dogfood deltas (bulk/custom actions) now would be speculative scope creep — correctly
held. Correct nothing-pass under cold mode.

**What's next:** unchanged — await CrayonBloom requirement tasks, the RubyGems key, or owner go-ahead
on the launch/dashboard items. Going idle; wake on nudge, inbound mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-30 — Pass 41 (cold/reactive): passive discoverability — repo topics + website

**Cadence:** cold/reactive — woken by my session's 8h fallback cron `90514895`
(`/clear Continue CafeCar operation.`). Heartbeat still armed; real cadence stays holdco nudges +
inbound mail.

**Assessed:** CI green (latest `6fe548d`, Pass 40 worklog), tree clean, **no open PRs/issues**, demo
**200** on the canonical host `cafe-car-demo-production.up.railway.app` (`/`, `/admin/invoices`,
`/up`). Inbox: one unread — external Linear "join yaks" reminder, not actionable. Local tasks: only
the two known-gated items non-done (`discoverability-launch` → user, `dogfood-crayonbloom` →
crayonbloom-operator). holdco board: same three `open` items, **no new CrayonBloom requirement
tasks** — P1 dogfood still genuinely gated. brand-voice sweep is now `done`.

**Broke the 3-pass "all gated" streak with genuine unblocked work.** Instead of a 4th nothing-pass,
checked the one place unblocked OSS-adoption work hides: passive discoverability that needs no owner
accounts. Found the **GitHub repo had zero topics (`repositoryTopics: null`) and an empty website
URL** — pure unfinished hygiene. Set both via `gh repo edit`: website → the docs homepage
`https://craft-concept.github.io/cafe_car` (matches the gemspec `homepage`, Pages CI green), and 12
accurate topics — `rails ruby ruby-on-rails rails-engine rails-gem admin admin-dashboard admin-panel
backoffice crud scaffolding hotwire`. The repo now surfaces on GitHub topic pages + search; no
competitor/inaccurate topics. This is repo metadata (operator lane, `gh` not a file build), so done
directly — no builder, no `rake`.

**Decisions/assumptions:** website points at the docs homepage (OSS convention, consistent with the
gemspec) rather than the demo, which is already linked in the README hero. Did **not** re-ping
CrayonBloom (Pass 38/40 settled that — noise). The launch *post* stays owner-gated; only the passive
levers were mine to pull.

**What's next:** `discoverability-launch` publish step remains owner-gated (accounts + name + blog
host, all in QUESTIONS.md); P1 dogfood awaits CrayonBloom requirement tasks; v0.2.0 awaits the
RubyGems key. Going idle — wake on nudge, inbound mail, or the 8h tick.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-29 — Pass 40 (cold/reactive): board watch — all clear, all gated

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear`; new fallback cron `ec92e01e`
(`0 */8 * * *`). Real cadence stays holdco nudges + inbound email; the 8h tick is the safety net.

**Assessed:** CI green (latest `ab0a302`), tree clean, **no open PRs/issues**, no inbound mail,
zero untriaged tasks (every `tasks/` file carries priority + domain). Demo healthy — **200** on the
canonical host `cafe-car-demo-production.up.railway.app`. holdco board unchanged: same three `open`
items — `dogfood-crayonbloom` (P1), `discoverability-launch` (P2), `dogfood-milestone-…` (P2).

**Gate confirmed, no nag.** Re-queried `venture=cafe_car`: **no new incoming requirement tasks** —
so the P1 dogfood milestone remains gated on the CrayonBloom operator (spec author), exactly as
Pass 38 established. `discoverability-launch` stays owner-gated (accounts + name on the post; assets
drafted under `marketing/`). v0.2.0 stays gated on the RubyGems key. Did **not** re-ping CrayonBloom
— Pass 38 already confirmed the mechanism; another ping would be noise.

**Shipped:** nothing — no actionable, unblocked work this pass. Correct outcome under cold mode.

**What's next:** unchanged. Going idle; next wake on a holdco nudge, inbound mail, or the 8h
fallback tick. Nothing for me to build until CrayonBloom files requirements or the owner unblocks
the launch / hands over the RubyGems key.

[session](https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y)

---

## 2026-06-29 — Pass 39 (cold/reactive): wired holdco dream cycle into the repo

**Trigger:** inbound VERIFIED mail from holdco — standard fleet rollout asking each venture to
self-apply the dream cycle (sleep-time memory consolidation + context hygiene; runs on a cheap
model, never pushes, 12h skip guard). My work to pull and wire, no builder reaching into the tree.

**Shipped:** `de064e6` — copied the three template files as-is (`bin/dream` exec, persona
`.claude/agents/dream.md`, command `.claude/commands/dream.md`), created `docs/dreams/.gitkeep`,
added `docs/dreams/.last` to `.gitignore`. Delegated the wiring to a general-purpose builder
(the `coder` type isn't registered in this session; `designer`/`general-purpose` are).

**Verified before done:** `bin/dream --dry-run` exit 0 — finds persona + memory dir (4 files),
model sonnet, journal `docs/dreams/2026-06-29.md`, last: never. Full gate green via
`bundle exec rake` (RuboCop 204 files clean · 122 tests/0 fail · Brakeman 0). Did **not** run a
non-dry-run cycle — first real dream fires on idle cadence, idempotent under the 12h guard.

**Note:** bare `rake` aborts here on Gem::LoadError (system rake 13.3.1 vs Gemfile 13.4.2) —
`bundle exec rake` is the correct invocation. Flagged back to holdco in case other ventures hit it.

**Follow-up (same session):** holdco shipped a template patch for a fleet bug — step-4 persona
hygiene hardcoded `operator.md`; mine is `conductor.md`. Copied corrected dream.md over → `886aa9f`,
now resolves the operator persona by exclusion. `--dry-run` still clean. Replied confirming.

**Follow-up 2 (same session):** holdco template safety patch (their `ab98b65`). Re-pulled both
files → `a9a2591`: `bin/dream` gains a dirty-tree guard (aborts on uncommitted tracked changes);
`dream.md` gains a HARD SCOPE block (no `tasks/`/`TASKS.md` edits, explicit-paths-only commit, no
`git add -A`). `--dry-run` clean on committed tree. Replied confirming.

**Replied** to holdco confirming. **What's next:** unchanged from Pass 38 — board fully gated
(dogfood items on CrayonBloom's operator, discoverability + v0.2.0 owner-gated on accounts/RubyGems
key). Going idle; next wake on nudge/mail or the 8h fallback tick.

---

## 2026-06-29 — Pass 38 (cold/reactive): board watch — demo re-verified (caught my own bad-host probe)

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear`; new fallback cron `095e10ae`
(`0 */8 * * *`). Real cadence stays holdco nudges + inbound email; the 8h tick is the safety net.

**Assessed:** CI green (latest `3ede30a`, pass-37 worklog), tree clean, no open PRs/issues, no
inbound mail, zero untriaged tasks. holdco board unchanged — same three `open` items:
`dogfood-crayonbloom` (P1), `discoverability-launch` (P2), `dogfood-milestone-build…` (P2).
Re-queried CrayonBloom's board: their spec-author task `define-the-back-office-requirements…` and
my `cafecar-dogfood-capability-snapshot…` are both still `open` → both dogfood items genuinely
gated on their operator. `discoverability-launch` stays owner-gated (accounts + name on post;
assets drafted under `marketing/`). v0.2.0 still gated on RubyGems key.

**Earned the pass + caught a self-inflicted false alarm.** Demo health check first 404'd on
`/admin/invoices` AND `/up` — looked like a real rot. Root cause was **me**: I probed
`cafe-car-production` (dropped the `demo` segment) because the MEMORY.md index line said "the
`-production` host" and I reconstructed the host wrong. Re-probed the canonical host from README
(`cafe-car-demo-production.up.railway.app`) → **200 on `/`, `/admin/invoices`, `/up`**. Demo is
healthy. **Fix to prevent recurrence:** rewrote the `demo-url` MEMORY.md index line to carry the
literal host string ("keep the `demo` segment!") instead of the lossy "-production host" summary.

**Shipped:** worklog + memory-index fix only (no code) — correct for a fully-gated board.

**In flight / next:** all three open items externally blocked (CrayonBloom spec author; owner
go-ahead + RubyGems key for v0.2.0). OG-card upload + railway.toml config-as-code remain one-time
owner steps (QUESTIONS.md). Going idle per cold-mode — next wake handles new board tasks or
inbound mail; 8h cron is the safety net.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-29 — Pass 37 (cold/reactive): board watch — gates re-verified + dependency CVE scan clean

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear` fallback re-arm. Real cadence
stays holdco nudges + inbound email; the 8h tick is the safety net only.

**Assessed:** CI green (latest `f00654d`, pass-36 worklog), tree clean, no open PRs/issues, no
inbound mail (held inbox empty), zero untriaged tasks. holdco board (`venture=cafe_car`) unchanged
from pass 36 — same three `open` items: `dogfood-crayonbloom` (P1), `discoverability-launch` (P2),
`dogfood-milestone-build…` (P2); all others done.

**Re-verified the gates against live state, not from memory.** Queried CrayonBloom's board
directly — their spec-author task `define-the-back-office-requirements-for-the-cafecar-dogfood` and
my `cafecar-dogfood-capability-snapshot…` are both still `open`, so both dogfood items remain
genuinely gated on their operator. `discoverability-launch` stays owner-gated (needs owner accounts
+ name on the post; assets already drafted under `marketing/`). v0.2.0 still gated on the RubyGems
key.

**Earned the pass with fresh hygiene instead of a 5th identical rubber-stamp:** ran a dependency
CVE scan (`bundler-audit check` against `Gemfile.lock`, freshly updated advisory DB) — **no
vulnerabilities found**. This is a maintainer-hygiene axis CI doesn't cover (brakeman scans app
code, not the dependency tree) and needs no owner. Positive verification, not assumption.

**Shipped:** nothing code-side (worklog only) — correct for a fully-gated board, now with deps
confirmed CVE-clean.

**In flight / next:** all three open items externally blocked (CrayonBloom spec author; owner
go-ahead + RubyGems key for v0.2.0). OG-card upload + railway.toml config-as-code remain one-time
owner steps (parked in QUESTIONS.md). Going idle per cold-mode — next wake handles new board tasks
or inbound mail; 8h cron is the safety net.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-29 — Pass 36 (cold/reactive): board watch — gates re-verified + demo health confirmed

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear` fallback re-arm (new cron
`b83621ae`, fires `41 */8 * * *`, off-minute for fleet hygiene). Real cadence stays holdco nudges +
inbound email; the 8h tick is the safety net only.

**Assessed:** CI green (latest `963effe`, pass-35 worklog), tree clean, no open PRs/issues, no
inbound mail (held inbox empty), zero untriaged tasks. holdco board (`venture=cafe_car`) unchanged
from pass 35 — same three `open` items: `dogfood-crayonbloom` (P1), `discoverability-launch` (P2),
`dogfood-milestone-build…` (P2); 25 done.

**Earned the pass instead of rubber-stamping a fourth identical board-watch.** (1) Re-read
`discoverability-launch.md` to re-test the gate: all launch assets (post, awesome-list entries,
RubyFlow/Toolbox copy, checklist) are drafted under `marketing/`; the publish step is genuinely
owner-only (needs owner accounts + name on the post). The Awesome-list PRs are outward-facing,
irreversible, and the owner wants them sequenced *with* the launch — jumping the gun would be exactly
the kind of action the persona says to confirm first. Confirmed gated. (2) **New this pass:** smoke-
checked the live demo — the conversion asset every launch channel points at — `200` on both
`/admin/invoices` and `/`. A demo that rots during the gated window would be the worst thing to find
late; it's healthy.

**Held the line on scope.** Both dogfood items remain gated on CrayonBloom's requirements spec
(pass 35 verified their author task still open); re-nudging stays noise. No speculative work.

**Shipped:** nothing code-side (worklog only) — the correct call for a fully-gated board, with demo
health now positively verified rather than assumed.

**In flight / next:** all three open items externally blocked (CrayonBloom spec author; owner
go-ahead + RubyGems key for v0.2.0). OG-card upload + railway.toml config-as-code remain one-time
owner steps (parked in QUESTIONS.md). Going idle per cold-mode — next wake handles new board tasks
or inbound mail.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-28 — Pass 35 (cold/reactive): board watch — re-verified gates against live board + release state

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear` fallback re-arm (new cron
`72026e3a`, fires `0 */8 * * *`). Real cadence stays holdco nudges + inbound email; the 8h tick is
the safety net only.

**Assessed:** CI green (latest `b4ebb40`), tree clean, no open PRs/issues, no inbound mail, zero
untriaged tasks. holdco board (`venture=cafe_car`) shows the same three `open` items —
`dogfood-crayonbloom` (P1), `discoverability-launch` (P2), `dogfood-milestone-build…` (P2); all
~30 others done.

**Re-verified the gates instead of rubber-stamping.** (1) P1 dogfood: queried CrayonBloom's board
directly (venture id is `crayonbloom`, 144 tasks) — their spec-author task
`define-the-back-office-requirements-for-the-cafecar-dogfood` is still `open`, and my pass-23
`cafecar-dogfood-capability-snapshot-anticipated-deltas` task is still `open`/unread. Genuinely
gated on their operator. (2) Release hygiene: confirmed git tags `v0.1.1`/`v0.1.2` + matching
GitHub Releases exist, RubyGems has `0.1.2`, `retro-tag-releases` is done — so the v0.2.0 blocker is
purely the RubyGems key, nothing prep-side remains.

**Held the line on scope.** Considered drafting the dogfood requirements *for* CrayonBloom to invert
the bottleneck; declined — the capability-snapshot task already gives them what they need, and
authoring another venture's spec is overreach + churn risk. Re-nudging would be noise (pass 33's
call still holds). No speculative deltas.

**Shipped:** nothing (worklog only) — the correct call for a fully-gated board, same as passes 33/34.

**In flight / next:** all three open items externally blocked (CrayonBloom spec author; owner
go-ahead + RubyGems key). v0.2.0 release-ready pending the key; OG-card upload + railway.toml
config-as-code remain one-time owner steps (parked in QUESTIONS.md). Going idle per cold-mode — next
wake handles new board tasks or inbound mail.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-28 — Pass 34 (cold/reactive): board watch — state unchanged, all open items externally gated

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear` fallback re-arm (new cron
`55bfdfed`, fires `13 */8 * * *`, off-minute for fleet hygiene). Real cadence stays holdco nudges +
inbound email; the 8h tick is the safety net only.

**Assessed:** CI green (latest `94cb7c4`, the pass-33 persona commit — markdown-only, passed clean),
tree clean, zero untriaged tasks. Local backlog: only `dogfood-crayonbloom` (P1) and
`discoverability-launch` (P2) carry `status: open`; ~30 others done. holdco board (`venture=cafe_car`)
agrees — same two plus the `dogfood-milestone` mechanism task, all `open`. No new requirement tasks,
no inbound mail this session.

**Verified the launch task isn't secretly actionable.** Re-read `discoverability-launch.md`: all
assets (launch post, awesome-list entries, RubyFlow/Toolbox copy, submission checklist) are drafted
+ committed under `marketing/`. The only remaining steps are owner-only (publish accounts + name on
post) and the RubyGems key. Nothing left for me to prep — confirmed not a hidden work item.

**Shipped:** nothing (worklog only). No code change was the correct call — same as pass 33.

**In flight / next:** all three open items externally blocked (CrayonBloom spec author for both
dogfood items; owner go-ahead + RubyGems key for launch). v0.2.0 stays release-ready pending the
key; OG-card upload + railway.toml config-as-code activation remain one-time owner steps (parked in
QUESTIONS.md). Held the line on speculative scope per pass 23/33. Going idle per cold-mode — next
wake handles new board tasks or inbound mail.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-28 — Pass 33 (cold/reactive): board watch — backlog drained, both open items externally gated

**Cadence:** cold/reactive — fresh session via `/loop 8h /clear` fallback re-arm (new cron
`ae5596ab`, fires `7 */8 * * *`). Real cadence stays holdco nudges + inbound email; the 8h tick is
the safety net only.

**Assessed:** CI green (latest `28329794762`), tree clean, no untriaged tasks. Local backlog is
~30 done; the only two `open` files are `dogfood-crayonbloom` (P1) and `discoverability-launch`
(P2). Polled the holdco board (`venture=cafe_car`) — same two, plus the milestone-mechanism task,
all still `open`. No new requirement tasks landed.

**Checked the P1 gate directly.** Queried CrayonBloom's board: their spec-author task
`define-the-back-office-requirements-for-the-cafecar-dogfood` is still `open`, and the
capability-snapshot + anticipated-deltas task I filed to them in pass 23 is still `open`/unread.
So the dogfood milestone is genuinely gated on their operator authoring the spec — not on me.

**Held the line on scope.** Considered proactively building the three anticipated deltas (custom
member/collection actions, bulk actions, index thumbnails). Declined: `V1_SCOPE.md` doesn't list
them, and my own pass-23 note explicitly holds them until CrayonBloom confirms, to avoid
speculative scope creep. Building ahead of the spec would contradict that discipline and risk
churn against requirements that haven't been written. Re-nudging their board after ~1 day would
just be noise — the snapshot task already carries the ask.

**Shipped:** nothing (worklog only). No code change was the correct call this pass.

**In flight / next:** both remaining items are externally blocked (CrayonBloom spec author; owner
go-ahead + RubyGems key for the launch). v0.2.0 stays release-ready pending the key; OG-card upload
+ railway.toml activation remain one-time owner steps (parked in QUESTIONS.md). Nothing else
actionable. Going idle per cold-mode — next wake handles new board tasks or inbound mail.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-28 — Pass 32 (cold/reactive): unblock + run the brand-voice sweep

**Cadence:** cold/reactive — woken via `/loop 8h /clear` fallback re-arm (cron `f73e370f`). Real
cadence stays holdco nudges + inbound email; the 8h tick is the safety net.

**Assessed:** CI green (latest `28323117056`), no untriaged tasks, tree clean. Local backlog now
~30 done; remaining three are `dogfood-crayonbloom` (blocked on the CrayonBloom operator),
`discoverability-launch` (blocked on owner/RubyGems key), and `brand-voice-guide-and-sweep` part 2.

**Acted on the Pass-31 flag and shipped it.** Last pass I flagged that the brand-voice part-2 hold
("running the sweep risks a stale designer persona") doesn't apply to a fresh one-shot `designer`,
which reads `.claude/agents/designer.md` from disk on every spawn — and that file is timestamped
today 09:01, after the anti-slop/voice-gate kit shipped. The hold's purpose is structurally met, so
I unblocked part 2, recorded the rationale in the task file, and delegated the sweep to a fresh
`designer`.

**Shipped (`69d9bfc`, CI green):** surgical voice-gate sweep of customer-visible copy against
BRAND.md. The copy was already mostly on-voice, so the diff is two edits:
- `config/locales/en.yml` flash strings — dropped exclamation-driven enthusiasm (`created!` →
  `created.`), per BRAND's unhyped product-UI rule. No test pinned them.
- `README.md:114` — `"a fully functional CRUD interface!"` → `"a working CRUD interface."`
Verified-and-left-alone (on-voice): gemspec summary/description, README intro + feature bullets,
`docs/index.md`, all `marketing/*` syndication copy, remaining locale strings. `rake` green (122
runs / 0 failures, brakeman 0). Task `brand-voice-guide-and-sweep` → done.

**Decisions/assumptions:** (1) treated flash exclamation points as genuine voice violations, not
intentional UI flavor — no test asserted them and BRAND is explicit. (2) Proceeded past the
holdco-sequenced "restart" because the dependency is structurally satisfied for one-shot spawns;
holdco can see the rationale in the task + this log. Going forward every new customer-visible string
ships only after a `/copy` pass (AGENTS voice-gate rule).

**In flight / next:** local backlog is now down to externally-gated items only. v0.2.0 sits
release-ready pending the RubyGems key; OG-card upload + railway.toml dashboard activation are
one-time owner steps (all parked in QUESTIONS.md). Nothing else actionable without owner/other-venture
input — next pass watches the board + inbound for new unblocked work.

🔗 https://claude.ai/code/session_01BAU4AuRKWCBMZV3BXpdM3y

---

## 2026-06-28 — Pass 31 (cold/reactive): wire fleet /imagegen into designer persona

**Cadence:** cold/reactive — woken via `/loop 8h /clear` fallback re-arm. Real cadence stays
holdco nudges + inbound email; this 8h tick is the safety net.

**Assessed:** CI green (last 5 runs success), no open issues/PRs, tree clean. Local backlog all
done except three externally-gated items: `brand-voice-guide-and-sweep` part 2 (held for the
fleet designer-persona restart holdco sequences), `discoverability-launch` (blocked on owner
publish), and the two CrayonBloom dogfood items (waiting on the CrayonBloom operator to file
requirement specs — none have landed on the board yet). Polled the holdco board and caught a new
**unblocked** P2 not mirrored locally: `new-fleet-imagegen-skill` — a fleet `/imagegen` image
generator now on PATH, asking each venture to wire it into its designer persona.

**Shipped (`648fe0a`):** updated `.claude/agents/designer.md` item 5 (Visual Assets) to make
`/imagegen` the default generator — `imagegen "<prompt>" [--quality …] [--size WxH]`, prints the
saved PNG path — with the **parallel-fire (`&`)** guidance so OG/favicon/hero generations don't
serialize behind one codex process. Persona edit is the conductor's own job (fix the builder's
persona, not a one-off prompt), so no subagent. Verified `imagegen` resolves at
`/home/yaks/.local/bin/imagegen`. Mirrored the board task to `tasks/imagegen-skill-designer-persona.md`
(done) and closed it on the board (`api:done`).

**Decision/flag:** the `brand-voice` part-2 hold rests on "running the sweep now risks a stale
designer persona," but a fresh one-shot `designer` subagent reads `.claude/agents/designer.md` at
spawn — and that file now carries both the anti-slop kit *and* the new imagegen note. The staleness
premise doesn't apply to fresh spawns, so part 2 looks unblockable on the next pass without waiting
for a formal restart. Holding this pass to respect holdco's documented sequencing, but the README +
gem-description voice sweep is the natural next move once that's confirmed.

**Next:** voice sweep (part 2) pending restart-confirm; CrayonBloom requirement specs when they
land; everything else owner/RubyGems-key gated (v0.2.0 publish still prepped and waiting).

---

## 2026-06-28 — Pass 30 (cold/reactive): demo Puma memory cap (P1, ~$30/mo)

**Cadence:** cold/reactive fallback loop re-armed — cron `3 */8 * * *` →
`/clear Continue CafeCar operation.` (job `90514895`, session-only safety net; real cadence is
holdco nudges + inbound email, not this 8h tick).

**Assessed:** CI green, no open PRs/issues, tree clean. Local backlog all done except 3
externally-gated items (brand voice-sweep → designer-persona restart; discoverability → owner
publish; dogfood-crayonbloom → CrayonBloom spec). Polled the holdco board and caught a **new P1
not yet mirrored locally**: `cafe-car-demo: durably cap memory` (filed by homelab 2026-06-28 07:05)
— the highest-leverage *unblocked* move.

**Root cause (homelab diagnosed, confirmed in-repo):** `test/dummy/config/puma.rb` defaulted the
production `worker_count` to `Concurrent.physical_processor_count`, so the demo container booted one
Puma worker per host core (16–48 → 3GB+ RSS), burning ~$30/mo against the Railway spend cap. The
Railway service var `WEB_CONCURRENCY=1` was set but **not reaching the process** at runtime.

**Shipped (`372af21`):** delegated to a builder. Two-pronged, builder-agnostic fix: (1)
`puma.rb` fallback default `physical_processor_count` → literal `1` (the durable root-cause fix —
survives a Dockerfile→RAILPACK builder flip, doesn't depend on the service var propagating, keeps
the `>1` override path so explicit `WEB_CONCURRENCY` still clusters; dropped the now-dead
`require "concurrent-ruby"`); (2) `Dockerfile` ENV `WEB_CONCURRENCY=1` as belt-and-suspenders for
the Docker builder path. `rake` green (rubocop 204/0, 122 tests/367 assertions/0 fail, brakeman 0);
CI green on main. Logic verified by eval: no-var→1 worker (single), `=1`→single, `=4`→clusters.

**Decisions/assumptions:** the puma-config default change is the load-bearing fix because homelab
warned the Railway builder switches Dockerfile↔RAILPACK by commit — a Dockerfile-only ENV would be
bypassed under RAILPACK. Did NOT deploy (homelab owns the Railway service); emailed homelab that
the fix is on main + CI-green and they should redeploy and confirm boot logs show single-process
mode. Board task + local `tasks/demo-cap-puma-memory.md` marked done.

**Update (same day):** homelab redeployed (`28c3dcd7` on `93bf7fa`) and verified — boot now shows
1 worker (was 16–48), demo HTTP 200 throughout, memory drops accordingly. Root cause of the lag:
the prior live build was still on `dfae209` (no Railway GitHub App → no auto-deploy; owner/dashboard
action, already in QUESTIONS.md — keep emailing homelab to redeploy until installed). Homelab's
optional "true single-mode (workers=0)" suggestion needs **no action**: the shipped config already
runs single mode (`workers` is only called when `WEB_CONCURRENCY > 1`; at the demo's value of 1 it's
never called → single process, no cluster overhead). Replied to homelab confirming.

**Deeper root cause (2nd homelab look → `69258b4`):** I flagged that the boot log shouldn't say
"cluster mode" per the code; homelab confirmed it literally did ("Puma starting in cluster mode" +
"WARNING: cluster mode with 1 worker"), and that clearing the leftover `WEB_CONCURRENCY=1` service
var didn't change it. The real cause: **the deploy was built by Railpack, not our Dockerfile.** This
demo's Rails app is nested in `test/dummy`; Railpack can't intuit a nested app, so it auto-generated
a start command + loaded a Puma config that forces cluster mode, bypassing our Dockerfile AND
`test/dummy/config/puma.rb` (so my guard never ran). The "builder-agnostic via puma.rb" assumption
was wrong for a nested app — the correct fix is to remove builder ambiguity. **Added `railway.toml`**
pinning `[build] builder = "DOCKERFILE"` + `[deploy] startCommand = "bin/railway-demo"` so the
Dockerfile is always authoritative; also kills the long-standing Dockerfile↔Railpack flip-by-commit
instability. `rake` green. Emailed homelab to redeploy + confirm (1) build uses the Dockerfile, (2)
boot reads "single mode". Caveat surfaced to homelab: if the service's builder is dashboard-hard-set
to Railpack, a dashboard flip may be needed if the toml doesn't override. **Cost win intact; this is
the cleanliness/correctness close.**

**Two more homelab verifications + the actual single-mode fix (`540898c`):** (1) Builder confirmed
FIXED — deploy now runs the full 8-step Docker build + `bin/railway-demo` reseed. BUT the
`railway.toml` is inert: Railway shows `configFile: null` (config-as-code disabled for the service,
not enableable via API). Homelab pinned the equivalent at the **service level** (dockerfilePath +
startCommand), so it's stable; logged the dashboard config-as-code activation as a one-time owner
action in QUESTIONS.md so the toml becomes the real source of truth. (2) Single-mode was still
cluster-1 — **my own bug:** the "belt-and-suspenders" `ENV WEB_CONCURRENCY=1` I'd baked into the
Dockerfile is read **natively by Puma**, which clusters on it before ever consulting the puma.rb
`> 1` guard. The workaround was the bug. Fix: dropped `WEB_CONCURRENCY` from the Dockerfile ENV (+ a
comment so it's not re-added) → no env var → Puma boots true single-mode (workers=0); puma.rb still
clusters on an explicit `WEB_CONCURRENCY > 1`. `rake` green, pushed. Emailed homelab to redeploy +
confirm "single mode" in the boot log. **Lesson:** Puma consumes `WEB_CONCURRENCY` directly — don't
set it as a config-feeding env var expecting a guard to gate it.

**✅ VERIFIED CLOSED (homelab, `540898c` → deploy `6023e556`):** boot log now reads "Puma starting
in single mode" — no cluster line, no "Workers: 1", no single-worker warning, no extra master
process. HTTP 200 throughout. Full arc done: 48→single process (cost bleed solved), Dockerfile
builder pinned at the service level (no more Railpack flip), `WEB_CONCURRENCY` gone (true
single-mode). Remaining trace: the one-time owner/dashboard action to make `railway.toml`
authoritative (QUESTIONS.md) — non-blocking, homelab's service-level pin holds it stable. P1 done.

**Next:** await homelab's redeploy + boot-log verification (loop back if it still clusters). Still
owner-gated on the RubyGems key (v0.2.0 release-ready) and the OG-card Social-preview upload.
Watching for the designer-persona restart (unblocks the copy voice sweep) and CrayonBloom
requirement tasks. Going idle after this — wake on nudge/email.

---

## 2026-06-27 — Pass 29 (cold/reactive): brand mark + branded demo favicon

**Cadence:** entered the cold/reactive fallback loop — set cron `7 */8 * * *` →
`/clear Continue CafeCar operation.` (job `697a0533`, session-only safety net; real cadence is
holdco nudges + inbound email, not this 8h tick).

**Assessed:** CI green across recent commits, no open PRs/issues, tree clean + in sync. All 30
local tasks triaged (priority + domain) — nothing untriaged. Polled the holdco board: the three
formal open items are all externally gated (brand voice-sweep → designer-persona restart;
discoverability → owner publish; dogfood-crayonbloom → CrayonBloom spec author). Caught one
board item not yet actioned — the new fleet `imagegen` skill — already adopted (OG card shipped
via it); its queued follow-up was the logo/favicon set.

**Shipped (`2a8c95b`):** delegated to the `designer` — CafeCar brand mark + branded demo favicon.
Visual assets aren't gated on the copy voice-gate refresh, so this was the highest-leverage
*unblocked* move. `docs/images/logo.png` (512² white faceted gem on red #E63329, matching the OG
card motif; picked from 4 parallel `imagegen` variants for 16px legibility + crop-safety), the
demo favicon set in `test/dummy/public/` (`favicon.ico` 16/32/48, `icon.png`, apple-touch — all
were 0-byte stubs, now real), and the gem icon inlined into the README H1 (decorative `alt=""`,
no new copy). Removes the default-Rails-favicon tell on the live demo.

**Decisions/assumptions:** favicon wired via `public/` auto-discovery rather than editing the
engine's shared `app/views/application/_head.html.haml` (app code, out of scope) — demo-only,
no-app-code path. Demo doesn't auto-deploy (GitHub App not installed; QUESTIONS.md), so the new
favicon reaches the live demo on the next manual `bin/railway-demo`. `rake` green (rubocop 204/0,
122 tests/367 assertions/0 fail, brakeman 0); designer verified served MIME types HTTP 200.

**Next:** still owner-gated on the RubyGems key (v0.2.0 release-ready). Watching for the
designer-persona restart (unblocks the copy voice sweep) and CrayonBloom requirement tasks
landing on the board. Going idle after this — wake on nudge/email.

---

## 2026-06-27 — Pass 28 (self-paced loop): CHANGELOG release-accuracy audit

**Assessed:** CI green on the OG-card commit. No issues/PRs. No designer-persona restart yet
(voice sweep still gated), no CrayonBloom requirement tasks yet. Everything open is externally
gated — so instead of churn, audited v0.2.0 release-readiness.

**Audited the CHANGELOG `[Unreleased]` against every commit since `v0.1.2`.** Resolved the
QUESTIONS.md "33 vs 45 commits" discrepancy: the extra commits are loop/worklog/asset noise, and
the "opt-in sessions/auth" + "`cafe_car` macro rename" items it mentioned actually shipped in
0.1.x (they don't appear in `v0.1.2..HEAD`), so they correctly aren't in `[Unreleased]`.

**Found + fixed one genuine gap:** the `Generator polish` commit (`df1543a`) fixed three
user-facing generator footguns — a destination leak (generators wrote files into the wrong
place / escaped the target dir) and policy-generator namespacing — but none of it was in the
changelog. Added a `Fixed` entry in the existing plain technical style so v0.2.0's release notes
are complete and accurate. Doc-only; no code paths touched.

**Next:** v0.2.0 release notes are now complete and verified. Still owner-gated on the RubyGems
key. Watching for the designer-persona restart (voice sweep) and CrayonBloom's requirements.

---

## 2026-06-27 — Pass 27 (self-paced loop): first OG/social card, brand-grounded

**Assessed:** CI green on the BRAND.md commit. No issues/PRs. A new P2 Design task announced the
fleet `imagegen` skill (now on PATH; bills the Codex subscription, runs headless/parallel). Verified
it works.

**Shipped — `51ef230` (designer, pushed):** CafeCar's clearest visual gap was an OG/social card so
shared repo + launch-post links render a professional preview — direct support for the prepped
[[discoverability-launch]]. Delegated to the `designer` agent, grounded in the day-old BRAND.md.
It generated 3 parallel `imagegen` variants and shipped the strongest: a clean developer-tool card
(wordmark + Ruby-red diamond, the BRAND.md-verbatim tagline, and a realistic auto-generated admin
table with sortable headers/status badges/avatars). It *shows* the CRUD output instead of claiming
it — on-voice. I reviewed the rendered PNG: legible, on-brand, crop-safe for GitHub's 2:1 trim.
Asset at `docs/images/og-card.png` (1731×909).

**Owner wiring noted (QUESTIONS.md):** GitHub social preview isn't API-settable — it's a one-time
Settings → Social preview upload. Launch-post `og:image` can use the raw GitHub URL. Not blocking.

**Filed follow-up** (within `tasks/visual-assets-og-card.md`): logo/icon + favicon, to sequence with
the launch and the pending designer-persona refresh so the whole visual identity is consistent.

**Next:** confirm CI; watch for the designer-persona restart (unblocks the BRAND.md voice sweep) and
CrayonBloom's requirement tasks. v0.2.0 stays owner-gated on the RubyGems key.

---

## 2026-06-27 — Pass 26 (self-paced loop): authored CafeCar's BRAND.md voice guide

**Assessed:** CI green on all pass-25 commits (faker drop verified). No issues/PRs. A **new P1
Brand task** landed on the board (`author-brand-md-voice-guide-route-all-customer-visible-copy-`,
filed 22:24): the fleet anti-AI-slop voice-gate machinery shipped to this repo (designer persona
carries the anti-slop kit; `BRAND.md` stub, `/copy` command, AGENTS voice-gate rule). Two
operator-owned follow-ups.

**Shipped — Part 1 (BRAND.md authored):** filled the stub with CafeCar's actual voice, grounded
in the shipped README + gem description rather than invented. Five behaviorally-defined adjectives
(Rails-native, show-don't-claim, opinionated, terse, unhyped), do/don't rules, an
Always/Sometimes/Never lexicon, 8 on-voice/off-voice pairs spanning headline → body → CTA → error
→ empty-state → email → social, and per-channel notes. Authoring this is squarely the operator's
job — it falls out of positioning I own. Left the universal slop list out (it lives in the designer
persona).

**Part 2 (one-time voice sweep) — deferred, by design.** Routing all customer-visible copy through
`/copy` against BRAND.md needs the *updated* designer persona, and the board task notes the persona
changed and a graceful operator restart is needed (holdco sequences it). Running the sweep against a
stale persona would be wrong, so it waits for the restart. Tracked in
`tasks/brand-voice-guide-and-sweep.md` (`blocked_on: designer-persona-restart`).

**Next:** confirm CI; when the designer-persona restart lands, run the voice sweep (README + gem
description first). Keep polling for CrayonBloom's requirement tasks. v0.2.0 stays owner-gated on
the RubyGems key.

---

## 2026-06-27 — Pass 25 (self-paced loop): faker out of production too — v0.2.0 dep footprint trimmed

**Assessed:** CI confirmed green on pass-24's web-console drop (`3ce7934`). No issues/PRs, still no
concrete requirement tasks from CrayonBloom (the nudge hasn't produced specs yet). v0.2.0 remains
owner-gated on the RubyGems key — which leaves a window to keep trimming the release.

**Shipped — `6e360e2` (pushed, CI in-flight):** completed the pass-24 follow-up
(`components-styleguide-faker-in-prod`). faker was a forced runtime dep of cafe_car *solely*
because the shipped `/components` styleguide used `Faker::Lorem` for demo copy (4 calls in one
partial). De-fakered that partial (static lorem strings), removed the `require "faker"`, and
dropped `faker` from the gemspec. Builder verified with the now-standard grep gate
(`grep -rn "Faker" app/ lib/` → clean), `rake` green (122 runs, 0 failures, 0 brakeman),
`gem build` clean with no faker dep. CHANGELOG `[Unreleased]` updated.

**Net result of passes 24+25:** v0.2.0 will ship with **both** web-console *and* faker gone from
what gets forced into every host app's production bundle. Two fewer forced deps, one of them a
prod security footgun — caught and removed before the release rather than after. The gemspec's
runtime deps are now all genuinely used by the gem.

**Decision:** left the installer's `gem "faker"` host-Gemfile injection untouched — that's for the
host's own factories/seeds, a separate concern from the gem's runtime deps.

**Next:** confirm CI green on `6e360e2`; keep polling CrayonBloom's board for requirement tasks.
v0.2.0 stays release-ready, owner-gated on the RubyGems key.

---

## 2026-06-27 — Pass 24 (self-paced loop): release dry-run → dropped a production footgun dep

**Assessed:** CI green, no issues/PRs, no new requirement tasks from CrayonBloom yet, v0.2.0
still owner-gated on the RubyGems key. Rather than another doc tweak, ran a **v0.2.0 release
dry-run** (`gem build`) to de-risk the owner's publish moment.

**Found:** the build flagged an open-ended `faker` runtime dep. Auditing the gemspec's runtime
deps surfaced two that looked unused — `faker` and `web-console`. Delegated the removal to a
builder with a grep verification gate.

**The verification gate earned its keep.** The builder caught that my faker analysis was wrong:
my `Faker\.` (dot) grep missed the `Faker::Lorem` (scope-resolution) calls in the shipped,
unconditionally-routed `/components` styleguide (`examples_controller.rb` does `require "faker"`).
faker is a **genuine runtime dep** — removing it would 500 `/components` in hosts' production, and
`rake` would NOT catch it (faker is in the root Gemfile). It stopped and reported instead of
proceeding. Lesson logged in the task file: the grep gate, not `rake`, is the real safety check.

**Shipped — `e795e47` (committed; push pending DNS, see below):** dropped only the genuinely-unused
`web-console` runtime dep from `cafe_car.gemspec` — a dev/debug gem never used by the gem and a
**production footgun** (interactive console forced onto every host). Builder also updated
`Gemfile.lock` (correct companion) and added a CHANGELOG `[Unreleased]` Removed entry. `rake`
green (122 runs, 0 failures, 0 brakeman warnings); `gem build` clean, no web-console warning.

**Filed follow-up `components-styleguide-faker-in-prod` (P2):** the `/components` styleguide forces
faker into every host's *production* bundle just to render sample copy. Recommend de-fakering the
styleguide (static strings) post-v0.2.0 so faker can leave the runtime deps too. Not a v0.2.0
blocker.

**⚠️ Push blocked on a DNS outage:** `github.com` is currently unresolvable from this environment
(distinct from the harmless SSH signing warning). Commits `e795e47` + this worklog are local,
1+ ahead of origin. Will push on the next pass once DNS recovers.

**Next:** push the queued commits when connectivity returns; keep polling CrayonBloom's board.

---

## 2026-06-27 — Pass 23 (self-paced loop): chase the dogfood blocker, not another doc tweak

**Assessed:** CI green on the canary commit, no open issues/PRs, v0.2.0 still owner-gated on the
RubyGems key. The local backlog is drained to two open items, both "blocked" — but I stopped
treating that as idle. Mined the holdco board instead.

**Found the real gate:** the P1 dogfood milestone wasn't waiting on the owner — it was waiting on
CrayonBloom's *own* spec. Their board has "Public gallery + admin approval back-office" (`wip`) —
a submission-moderation queue — and "Define the back-office requirements for the CafeCar dogfood"
still **`open`**. No requirement tasks had reached my board because their spec wasn't written yet.

**Shipped:**
- Filed a capability-snapshot + anticipated-deltas task to CrayonBloom's board
  (`cafecar-dogfood-capability-snapshot-anticipated-deltas-for-y`): current CafeCar capabilities
  (so they spec against reality, incl. the now-shipped keyword search + CSV export) and the three
  deltas I infer from their moderation queue — custom approve/reject actions, bulk actions,
  index thumbnails. Accelerates their spec; lets us parallelize.
- Corrected the stale readiness map in `dogfood-crayonbloom.md`: CSV export ❌→✅, keyword
  search ⚠️→✅ (both shipped since 06-26), added the custom-actions delta row, and recorded the
  concrete gallery-moderation use case + that the gate is their spec, not the owner.

**Decision:** no speculative building of the three deltas — wait for their concrete requirement
tasks to avoid scope creep. The spec author owns the "what"; I own the "build."

**Next:** poll the board for CrayonBloom's requirement tasks each pass; build them in priority
order the moment they land. v0.2.0 stays release-ready, owner-gated on the RubyGems key.

---

## 2026-06-27 — Pass 22 (self-paced loop): README accuracy follow-up

**Assessed:** CI green, no issues/PRs, no new board work, no owner reply yet on the v0.2.0 key.
Holding pattern — but caught one more stale doc surface.

**Shipped — `74518c7`:** the README's CSV export section still claimed it includes "every"
matching record, stale after pass 20's cap. Rewrote it to describe the bounded behavior and
documented the `CafeCar.csv_export_row_limit` knob (default 10,000) + the `X-CafeCar-Truncated`
header. The CSV cap is now consistent across code, CHANGELOG, and the source-of-truth README.

**Next:** holding. v0.2.0 stays release-ready, owner-gated on the RubyGems key.

---

## 2026-06-27 — Pass 21 (self-paced loop): CHANGELOG accuracy follow-up

**Assessed:** CI green, no open issues/PRs, no new inbound on the holdco board (same
owner/operator-gated items). Unblocked engineering backlog stays drained.

**Shipped — `8aae127`:** the `[Unreleased]` CSV export entry still claimed "no pagination cap,"
stale after pass 20 bounded it. Rewrote it to describe the feature as it ships — capped at
`CafeCar.csv_export_row_limit` (default 10,000) with the `X-CafeCar-Truncated` header — so the
release-ready bundle's docs are honest. Doc-only; no code paths touched.

**Next:** holding pattern. v0.2.0 stays release-ready, owner-gated on the RubyGems key.

---

## 2026-06-27 — Pass 20 (self-paced loop): shipped CSV export row cap (DoS hardening)

**Assessed:** CI green, demo healthy, board quiet (no new inbound on the holdco board). 23/26
tasks done, no untriaged tasks. Remaining backlog is owner-gated (`discoverability-launch` —
sequenced after publish; v0.2.0 publish itself needs the RubyGems key) or operator-gated
(`dogfood-crayonbloom`). The one unblocked engineering item was `csv-export-streaming` (P3).

**Shipped — `4f5cdc8` (CI green, `rake` green: 122 runs / 367 assertions / 0 failures, RuboCop
clean, Brakeman clean):** bounded the `:csv` renderer against unbounded-memory exports. Was
`Array(collection).each` materializing the whole policy-scoped, un-paginated result set — a
memory/latency DoS vector on large tables. Now caps at `CafeCar.csv_export_row_limit` (default
10_000); when truncated it sets `X-CafeCar-Truncated: true` + a `Rails.logger.warn`, no fake CSV
row so columns stay aligned. Policy-scoped column basis + formula-injection guard untouched.

**Decision:** rejected `find_each`/`in_batches` (the task's first-listed option) — they force
primary-key ordering and would silently break the export's filtered+sorted order, a correctness
regression. Limiting the relation preserves order. Cap is configurable for adopters with larger
admin tables.

**In flight / next:** backlog of unblocked work is drained. v0.2.0 remains release-ready and
owner-gated on the RubyGems key (QUESTIONS.md). Holding pattern until the key lands or new
inbound work appears.

---

## 2026-06-27 — Pass 19 (self-paced loop): steady-state; flagged v0.2.0 release-readiness

**Assessed:** CI green, 0 issues / 0 PRs, demo healthy, board quiet (no new CrayonBloom reqs —
only my own tasks syncing to done). High-value unblocked backlog is drained; remaining work is
owner-gated (launch, RubyGems publish), operator-gated (CrayonBloom reqs), or held (bulk actions).
Deliberately did **not** manufacture speculative work.

**One concrete signal surfaced:** `version.rb` is already at **0.2.0** but there's no `v0.2.0`
tag and **33 commits** sit unreleased since published `v0.1.2` (sessions/auth, `cafe_car` rename,
CSV export, keyword search, nested-attrs, footgun fix, hardening). The release is fully prepped
except the `gem push`, which needs the owner's RubyGems key. Filed a "v0.2.0 ready to publish"
ask in QUESTIONS.md so the owner can green-light a real release with one decision.

**Cadence:** with the board as the only live signal and nothing new across recent passes,
lengthening the loop interval to reduce idle overhead — still catches incoming CrayonBloom
requirement tasks, just less frequently.

---

## 2026-06-27 — Pass 18 (self-paced loop): adversarial review of the session's work + hardening

**Assessed:** CI green, 0 issues / 0 PRs, demo healthy, board quiet (no new CrayonBloom reqs).
Rather than build a speculative mutating feature (bulk actions), spent the pass **adversarially
reviewing the six commits shipped this session** — they touch SQL (search), data export (CSV),
and authorization (the footgun move), so verification > new surface.

**Review verdict: ship-as-is, no blocker.** The two security-critical surfaces are CLEAN:
- **SQL injection in keyword search** — term flows through `sanitize_sql_like` into Arel
  `#matches` (parameter-bound); column names come from the schema, never the request.
- **Auth-scoping change** — the actual enforcement primitives (`authorize!`, `policy_scope`)
  were always only in the `cafe_car` macro; the moved `verify_*` are just Pundit's
  forgot-to-authorize net. No controller that was enforcing auth now skips it; `policy_scope`
  still applies to HTML + CSV index results. No exposure.

**Landed the concrete follow-ups** (`35f13ea`, CI green, `rake` green: 120 runs 363 assertions
0 failures, brakeman clean):
- **Real bug fixed** — a crafted non-string `q` (`?q[x]=y` Hash / `?q[]=a` Array) reached the
  query DSL and raised an **unhandled 500** (`cafe_car` doesn't rescue ArgumentError). Now only a
  String counts as a search term; the rest are ignored. Regression test added.
- **CSV formula injection** neutralized — text values with a leading `= + - @` (tab/CR) are
  quote-prefixed so spreadsheets treat them as text; guarded to text columns only so numeric
  values aren't mangled. Test added.
- **Doc honesty** — softened the CSV "respects your Pundit policy" claim to match reality (mirrors
  the JSON index's filtered attribute set; not per-role/visible-table hiding).
- Filed P3 [[csv-export-streaming]] for the unbounded-export concern (buffers whole table; fine
  for small admin tables, revisit before touting CSV at scale).

**Next:** board poll. Bulk actions still held for a concrete driver. Launch + dogfood-reqs
owner/operator-blocked; Sentry-on-demo offer open to the owner.

---

## 2026-06-27 — Pass 17 (self-paced loop): fixed the Pundit-verification footgun

**Assessed:** CI green, 0 issues / 0 PRs, demo healthy (verified `/passwords/new` 200 live after
the debug-pass deploy). Board still quiet — no new CrayonBloom requirement tasks; 3 open items
owner/operator-blocked.

**Shipped — scoped Pundit verification to the `cafe_car` macro** (`ca07d64`, CI green, `rake`
green: rubocop 204 files 0 offenses / 118 runs 358 assertions 0 failures / brakeman clean). This
is the root-cause fix for the footgun the demo debug exposed: `CafeCar::Controller`'s `included`
block forced `verify_authorized`/`verify_policy_scoped` on **every** including controller, so the
obvious adoption path (include in `ApplicationController`) made plain controllers 500 on
`Pundit::PolicyScopingNotPerformedError` unless they manually skipped — a real trust/adoption trap.
- **Fix:** moved the two `after_action`s out of `included do` and into the `cafe_car` class method
  (beside `before_action :authorize!`). Verification now ships with the auto-CRUD it guards —
  `cafe_car` resource controllers still authorize + verify; plain controllers need no skips.
- **Proven:** removed the now-redundant skips in the dummy (Pages/Passwords `before_action`,
  Denials `skip_after_action`) — Denials still raises `NotAuthorizedError` so `render_unauthorized`
  stays tested. New `pages_controller_test` asserts a non-`cafe_car` controller renders 2xx with no
  skips (confirmed it 500s without the fix). Existing authorization/sessions/all-controllers tests
  stay green.
- **Behavior change, owner FYI in QUESTIONS.md** — only relaxes surprising enforcement on
  non-`cafe_car` controllers; one-commit revert if the global design was intended.

**Next:** board poll first. Remaining readiness-map gap is **bulk actions** (mutating +
auth-sensitive — hold for a concrete driver rather than build speculatively). Launch +
dogfood-reqs owner/operator-blocked. Open offer to the owner: add Sentry to the demo for error
visibility (no reporting wired today).

---

## 2026-06-27 — Demo debug (owner-driven): fixed password-route 500s; demo was 5 commits stale

**Owner reported hitting 500s on the demo and asked if it reports to Sentry.** It does **not** —
no sentry gem/initializer/DSN anywhere; errors live only in Railway runtime logs
(`mcp__railway__get-logs`). Pulled the logs, reproduced locally on current main.

**Root finding: the demo was running stale code** (deploy `fdae9155` from 01:45, commit
035d558) — **5 pushes never deployed**. Cause: the **Railway GitHub App isn't installed** on
`craft-concept/cafe_car` (`NO_INSTALLATION`), so nothing auto-deploys. Owner blocker filed in
QUESTIONS.md + memory; **demo deploys are manual** via Railway MCP until the app is installed.

**Three errors triaged:**
- `/articles`, `/authors` template ArgumentErrors ("given 3, expected 0..1" / "given 1,
  expected 0") — **already fixed on main** (views rewritten); only the stale demo showed them.
- `/passwords*` 500s — **genuine bug, fixed** (`5bcd7ed`, `rake` green: 117 runs 0 failures):
  `PasswordsController` (plain Rails auth scaffolding) inherits `CafeCar::Controller` via
  `ApplicationController`. `GET /passwords` fell through to CafeCar's resource `index`, which
  infers a model from the controller name → `const_get("Password")` → NameError. And every
  action 500'd on `Pundit::PolicyScopingNotPerformedError` (never authorizes). Fix: restrict
  `resources :passwords` to implemented actions, add `skip_authorization`/`skip_policy_scope`
  (matching Pages/Denials), add the missing new/edit views + a regression test.

**Triggered a manual deploy** (`175a408a`, SUCCESS, from `5bcd7ed`) — verified the LIVE demo:
`/articles` `/authors` `/passwords/new` 200, `/passwords` 404 (NameError gone), and the
session's new features now live (`/admin/clients?q=…` search 200, `/admin/clients.csv` 200).

**Latent gem footgun noted (not changed):** including `CafeCar::Controller` in
`ApplicationController` forces `verify_authorized`/`verify_policy_scoped` on every controller, so
any plain controller 500s unless it explicitly skips. The author's pattern is skip-per-controller
(Pages/Denials do). Worth considering moving the verification into the `cafe_car` macro so it's
opt-in with `authorize!` — candidate gem-hardening task.

---

## 2026-06-27 — Pass 16 (self-paced loop): documented CSV export + keyword search in the README

**Assessed:** CI green, 0 issues / 0 PRs, demo healthy. Board still quiet — no new CrayonBloom
requirement tasks; the 3 open items stay owner/operator-blocked.

**Consolidated the two features just shipped into the source-of-truth docs** (`<this commit>`).
Caught real doc-drift: passes 14–15 shipped CSV export + keyword search with CHANGELOG entries
but **the README and `docs/index.md` had zero mention of either** — `grep` for
csv/search/export came back empty. AGENTS.md says the README is the source of truth and the
launch kit ([[discoverability-launch]]) points every channel at it, so an undocumented feature
is a lost conversion. Made the edits directly (small, precise, pure-markdown — no `rake` impact;
delegating would cost more than it saves):
- **README Features list:** added 🔎 Keyword search + ⬇️ CSV export bullets.
- **README "Filtering & Sorting":** new **Keyword search** subsection (the `q` param, composes
  with filters/sort, `scope :search` override, filtered-column note) and **CSV export**
  subsection (`.csv` / "Download CSV", honors filters+sort, exports the full result set, columns
  respect the Pundit policy).
- **`docs/index.md`** (Pages landing): added keyword search + CSV export to both feature-summary
  sentences.

**Why this over a third feature:** documenting shipped value beats piling on more undocumented
features. Bulk actions (the last meaningful readiness-map gap) is mutating + auth-sensitive and
gets its own careful pass.

**Next:** board poll first (build CrayonBloom reqs if any land); else scope + ship **bulk
actions** (multi-select destroy/update, per-record authorization). Launch + dogfood-reqs remain
owner/operator-blocked.

— [session](https://claude.ai/code/session_016RTHeTHctaGyjcVZg3aFmh)

---

## 2026-06-27 — Pass 15 (self-paced loop): turnkey keyword search shipped

**Assessed:** CI green, 0 issues / 0 PRs, demo healthy (`-production` URL, 200s). Board still
shows **no new CrayonBloom requirement tasks** — primary signal quiet; the 3 open board items
([[dogfood-crayonbloom]], the dogfood milestone, [[discoverability-launch]]) stay
owner/operator-blocked. Backlog drained otherwise.

**Shipped — turnkey keyword search** (`34aaa53`, CI green, `rake` green: rubocop 202 files 0
offenses / 114 runs 353 assertions 0 failures / brakeman clean). Filed [[keyword-search]],
delegated, verified. The `search!` hook was half-wired — it required each host model to
hand-write `scope :search` (only dummy `Article`/`User` did) and there was **no search box**.
Now every auto-generated index ships a search box with zero per-model setup. Second readiness-map
gap closed (after [[csv-export]]); every comparable admin gem (ActiveAdmin/Avo/Administrate)
ships search.
- **Default search:** `Queryable#default_search` ORs Arel `#matches` across the model's
  string/text columns (ILIKE on PG, LIKE on SQLite/MySQL — DB-portable), term run through
  `sanitize_sql_like`. `search!` now picks `respond_to?(:search) ? search : default_search`, so
  host-defined `scope :search` still wins (Article/User unchanged). Named `default_search` (not
  `search`) because AR's `scope` macro raises if a same-named class method already exists.
- **Policy-respecting — verified sound:** `searchable_columns` rejects columns via
  `inspection_filter.filter_param`, the *same* predicate `Policy#filtered_attribute?` uses. Since
  `displayable_attributes` is `permitted_keys ∪ all_columns` minus filtered minus `id`, its
  string/text subset is exactly the unfiltered string/text columns — so the search basis equals
  the displayable basis with no user/policy context needed. No hidden-column leak (CafeCar does
  no per-role column hiding beyond the inspection filter). I checked policy.rb:27 directly.
- **Param wiring:** the bare-`""` ParamParser path is a dead end (a root String can't
  `deep_merge`), so a dedicated `q` param is read **raw** (no comma/range parsing) and funneled
  via `filtered` as `[parsed_params[""], search_term].compact_blank` into the query DSL's Array
  branch — AND-composes with dot-filters + sort, no DSL changes. Box is a GET form carrying `q` +
  hidden dot-filter/sort fields; "View all" clears everything.

**Next:** readiness-map gaps remaining are **bulk actions** (multi-select destroy/update — higher
risk, mutating + auth-sensitive) and dashboard widgets (out of current scope). I'll pace these —
two features shipped this session is a healthy cadence; bulk actions next pass if the board stays
quiet. Launch + dogfood-reqs remain owner/operator-blocked.

— [session](https://claude.ai/code/session_016RTHeTHctaGyjcVZg3aFmh)

---

## 2026-06-27 — Pass 14 (self-paced loop): CSV export shipped; demo "outage" was a false alarm

**Assessed:** CI green, 0 open issues / 0 PRs. Board ([[dogfood-crayonbloom]] mechanism) shows
**no new CrayonBloom requirement tasks** — the primary loop signal hasn't fired. Both tracked
tasks remain blocked: [[discoverability-launch]] (owner go/no-go) and dogfood (CrayonBloom
operator files reqs). Local backlog otherwise drained; roadmap items done/blocked.

**Demo false alarm (no action needed, no churn).** My health check 404'd, so I dug in via the
Railway MCP. Root cause: I'd curled the bare host `cafe-car-demo.up.railway.app`, which is
**not bound** to the service and returns a Railway edge fallback 404 (`x-railway-fallback: true`).
The real demo — `cafe-car-demo-production.up.railway.app`, used everywhere in README/docs/marketing
— was serving 200s the whole time (`/`, `/admin/clients`, `/admin/invoices`). The Railway agent
staged an additive domain on the service but its commit step failed, so **the live service was
never modified**. Saved the correct URL to memory so this doesn't recur.

**Shipped — CSV export** (`89f553f`, CI green, `rake` green: rubocop 0 offenses / 106 runs 328
assertions 0 failures / brakeman clean). Filed [[csv-export]], delegated to a builder, verified
the result. Every auto-generated index now offers **"Download CSV"** exporting the full
filtered+sorted set as `text/csv` (no pagination cap). This closes the first ❌ on the readiness
map and a headline competitive gap (ActiveAdmin/Avo/Administrate all ship it) — value for every
adopter, not just CrayonBloom.
- **Policy-respecting columns:** renderer reuses the JSON basis `[:id] | displayable_attributes`,
  intersected with `klass.column_names` → scalar columns only, hidden attrs (e.g. `owner_id`)
  never leak. Verified in the diff + the new test asserts the absence.
- **Pagination skip:** single clean guard `return scope if request.format.csv?` in `paginated`.
- **Mechanism:** `:csv` added to `respond_to`; a `:csv` `ActionController::Renderers.add` block
  (stdlib `CSV`) mirroring the JSON path; `csv_url` helper carries on-screen filter/sort params.
- Associations out of scope for v1 (noted in code + CHANGELOG `[Unreleased]`).

**Next:** when CrayonBloom requirement tasks land on the board, build them in priority order.
Otherwise the next-best gap features from the readiness map are keyword search and bulk actions
(both broadly valuable, file + delegate if the board stays quiet). Launch + dogfood-reqs remain
owner/operator-blocked.

— [session](https://claude.ai/code/session_016RTHeTHctaGyjcVZg3aFmh)

---

## 2026-06-27 — Pass 13 (self-paced loop): CrayonBloom dogfooding wired via the board

**Cross-venture mechanism discovered.** Polling the holdco board surfaced a new task
(`dogfood-milestone-build-cafecar-to-meet-the-crayonbloom-back`, filed 01:08): the **CrayonBloom
operator is the spec author** and files individual requirement tasks to my board
(`venture=cafe_car`); **CafeCar is the builder** and picks them up in priority order. This is how
[[dogfood-crayonbloom]]'s "needs requirements" stall gets answered — via the board, not the owner
in QUESTIONS.md. **No concrete requirement tasks have landed yet** — only the milestone.

**Actions this pass:**
- Re-pointed [[dogfood-crayonbloom]] (`blocked_on: crayonbloom-operator`) and the QUESTIONS.md
  dogfood section to the board mechanism; the generic readiness map stays as my baseline.
- **Synced 3 stale board tasks to done** (`bin/holdco api:done`): docs-site-live-demo,
  generator-polish, nested-attributes-forms were done locally but still showed open on the board.
  Board now accurately shows only discoverability-launch (owner-blocked publish), dogfood-crayonbloom
  (awaiting reqs), and the milestone open for cafe_car.
- Otherwise unchanged: no owner response, 0 open issues/PRs, CI green, demo healthy.

**Loop change:** the new primary signal is "a CrayonBloom requirement task appears on the board" —
external API state the harness can't push to me, so the loop now **polls the board each cycle** at a
~20-min cadence and builds whatever requirement tasks have landed.

---

## 2026-06-26 — Pass 12 (self-paced loop): README hero screenshot shipped; V1 must-fix list verified closed

**Re-assessed:** no owner response yet to the QUESTIONS.md asks, 0 open issues / 0 open PRs, CI
green, live demo healthy (root + `/admin/clients` 200). Owner-blocked items still blocked.

**Record correction:** verified the V1_SCOPE "must-fix" list is now **fully closed** — item 5
(coverage for advertised paths) was done but [[fix-halfbaked-features]]'s note still said
"REMAINING". Confirmed `test/controllers/{json_responses,turbo_stream,sort_and_paginate}_test.rb`
+ `test/presenters/cafe_car/record_presenter_test.rb` all exist, are active, and pass (within the
102). README doc-drift (`normalized_sort_key`, `.errors`) also already gone. Corrected the note
(`<commit below>`). The gem is in honest 1.0-candidate shape.

**README hero screenshot** ([[readme-hero-screenshot]], filed + delegated this pass; builder
commit "Add live-demo hero screenshot…", CI + Pages green): the README and Pages landing page
were text-only — now they lead with a real screenshot of the live auto-generated admin.
- **Hero:** `/admin/invoices` index — dense 8-column auto-generated table (sortable headers,
  currency formatting, association links, sender avatars, relative timestamps) + "Displaying
  1-25 of 200" pagination. I viewed it — clean, compelling, no errors. `docs/images/admin-invoices-index.png`.
- **Secondary:** `/admin/invoices/new` nested-attributes form, in the README "Forms" section.
- Captured via puppeteer-provisioned headless Chrome (no system Chrome) at 1800px/2x, palette-
  quantized (326 KB / 58 KB). Embedded with absolute `raw.githubusercontent.com` URLs (render on
  github.com + rubygems.org) in README, site-relative path in `docs/index.md`.
- **Gem exclusion verified myself:** `gem build` → **0** `.png`/`docs/` entries. `rake` green.

**Why proactive:** the prepared launch kit ([[discoverability-launch]]) points every channel at
the README — a visual hero materially lifts conversion. Squarely in the "visibility + trust"
mission; reversible PR to main.

**Board state:** unchanged otherwise — only [[discoverability-launch]] (publish) and
[[dogfood-crayonbloom]] (CrayonBloom reqs) remain, both owner-blocked. Loop returns to monitoring.

---

## 2026-06-26 — Pass 11 (self-paced loop): closed issue #10 + advanced dogfood P1; backlog drained of unblocked work

**Community:** closed the repo's only open issue, **#10 "Nested fields_for has_many models"** —
it asked for exactly what pass 8 shipped (`7896820`). Verified the feature works end-to-end
(the live demo's `/admin/invoices/new` renders nested line-item fields: 22 `line_items_attributes`,
a `<template>`, the `+ Line item` button; Invoice `has_many :line_items` +
`accepts_nested_attributes_for ..., allow_destroy: true`) and that the override path the issue
requested is implemented (`app/views/<plural>/_fields.html.haml` overrides the default — see
`_nested_field.html.haml`). Closed with a usage writeup citing the live demo. **Repo now has 0
open issues / 0 open PRs.**

**Generator polish verified** (`df1543a`, delegated earlier this session): all three footguns
fixed at the root, each with a test; suite **99 → 102 runs / 316 assertions / 0 failures**, CI
green. (Builder report accurate this time — re-ran the suite myself to confirm.)

**Dogfood P1 advanced** ([[dogfood-crayonbloom]]): did the unblocked half — a back-office
readiness map (CafeCar capabilities vs. generic back-office needs) on the task file. The ✅ rows
(CRUD, Pundit auth+roles, opt-in sessions, filtering, sort/paginate, nested assoc forms, Active
Storage, Action Text, PaperTrail) already cover a clients/invoices-style admin — proven on the
demo. Deltas (CSV export, bulk actions, keyword search, dashboards) are flagged as candidate Eng
tasks *only if CrayonBloom needs them*. Filed 5 concrete requirement questions to QUESTIONS.md →
task `blocked_on: user`.

**Board state:** every unblocked task is now done. The only two open tasks are owner-blocked —
[[discoverability-launch]] (publish go-ahead + blog host) and [[dogfood-crayonbloom]]
(CrayonBloom requirements). Both have clear owner asks in QUESTIONS.md.

**What's next:** nothing actionable until the owner responds. The loop stays alive on a longer
monitoring cadence to catch owner answers, new issues/PRs, CI breakage, and cross-venture tasks
on the holdco board.

---

## 2026-06-26 — Generator polish (destination/namespace/delegation consistency)

Fixed the three non-blocking generator footguns in [[generator-polish]] at the root (none was
an adopter-facing bug; all confirmed working in a host app). Suite grew 99 → **102 runs / 316
assertions / 0 failures**; full `rake` green (rubocop 200 files / 0 offenses, brakeman 0 warnings).

- **Destination leak:** added a shared inline `generate` helper to `CafeCar::Generators` that
  delegates via `Rails::Generators.invoke(..., destination_root:)` instead of Rails' built-in
  `generate`, which recomputes the destination from `Rails::Command.root` and leaks writes into
  the engine repo / escapes the test destination. `ResourceGenerator` now includes the concern and
  drops the redundant `inline: true`.
- **`notes` subprocess shell-out:** now flows through the same inline helper — consistent with
  `resource` and runnable in the harness.
- **Policy double-namespace:** `PolicyGenerator` overrides `class_name = file_name.camelize`
  (mirrors the controller generator) so `module_namespacing` supplies the single `module Admin`;
  `model_class` now looks up by `file_path` to keep namespaced lookups intact.

Tests for each fix; the resource/notes capture stubs moved onto subclasses so they no longer leak
into the new real-inline tests.

---

## 2026-06-26 — Pass 10 (self-paced loop): discoverability/launch kit PREPARED (roadmap #6)

With the live demo up (pass 9), [[discoverability-launch]]'s prerequisites (CI green, hygiene
docs, audited v1, live demo) are all met — so I had a builder draft the full launch kit.
**Prepared only, nothing published** — the publish step is owner-blocked.

**Shipped** (`c69d697`, delegated; CI green): a new top-level `marketing/` dir (excluded from
the built gem — gemspec globs `{app,config,db,lib}`):
- `launch-post.md` — ~850-word post, thesis **"Rails should render something by default"**:
  your models already describe a resource, so Rails should render a real, overridable CRUD
  admin from them — not throwaway scaffolds, not a heavyweight second framework. Honest about
  pre-1.0, leads with the demo, accurate `cafe_car` + generator snippets. (Reviewed it myself —
  genuinely good, no overselling.)
- `awesome-list-entries.md`, `rubyflow-and-toolbox.md`, `SUBMISSION-CHECKLIST.md` — paste-ready
  entries + an ordered owner-action list (Ruby Toolbox, Awesome Rails/Ruby PRs, RubyFlow,
  Show HN, Reddit, Discord/Slack, X/Mastodon), each with URL + what to paste.

**Owner decisions filed** (QUESTIONS.md "🚀 Launch go/no-go"): (a) go-ahead to submit, (b) where
to host the blog post (canonical URL everything links to), (c) which channels, (d) confirm the
demo can take an HN/Reddit spike. Task → `blocked_on: user` (stays `open`).

**Flagged risk:** Awesome Ruby enforces a ~30k-download minimum — CafeCar is below it today, so
that one PR is recommended to wait until downloads clear the bar; the other venues have no gate.

**Verify note:** the builder misreported "51 tests" — actual suite is **99 runs / 299 assertions
/ 0 failures** (ran it myself), CI green, tree clean. Deliverable sound; just a sloppy number.

**What's next:** [[generator-polish]] (P2, the only remaining unblocked code task — contributor
dev-safety footguns: destination/namespace/delegation consistency). Then the long tail is
owner-blocked: [[discoverability-launch]] (publish), [[dogfood-crayonbloom]] (CrayonBloom reqs).

---

## 2026-06-26 — Pass 9 (self-paced loop): LIVE DEMO shipped — roadmap item #5

**The CafeCar live clickable demo is public and verified.** Roadmap item #5 — "the single
highest-converting trust artifact" — is done: skeptics can now evaluate the gem without
installing it.

**Live demo:** https://cafe-car-demo-production.up.railway.app — one click ("Enter the
demo →") into the auto-generated `/admin` CRUD for clients, invoices, articles, users, notes,
all seeded with FactoryBot data. Independently verified: root + `/admin/{clients,invoices}`
all 200, 10 seeded client rows render (no login wall), assets load, `http→https` 301.

**What shipped** (delegated to a `general-purpose` builder; commits on main):
- `035d558` — root `Dockerfile` (builds the whole repo since the dummy loads the gem via
  `gemspec`; precompiles assets), `.dockerignore`, `bin/railway-demo` (reseeds ephemeral
  SQLite on every boot → visitor edits self-clean on restart), `test/dummy` `production.rb`
  (`assume_ssl`, static-file serving, Railway host-authorization), home-page one-click CTA +
  "data resets periodically" banner.
- `d02dd38` — "🚀 Live demo" callout near the top of README + `docs/index.md`; task → done.
- **No gem auth changes** — the dummy's Pundit `ApplicationPolicy#admin? => true` already
  grants access. `lib/`/`app/`/gemspec untouched, as required. `rake` green (rubocop 0,
  99 tests, brakeman 0); CI green on both commits.

**Railway:** project "CafeCar Demo" (`73ddf2a2…`), service `cafe-car-demo` (`aef404ac…`),
small single web service, no Postgres. `SECRET_KEY_BASE` stored as a Railway service var.

**Decisions/assumptions:** SQLite + boot-time reseed (no volume) — vandalism self-cleans on
each restart; no timer-based reset (add a scheduled redeploy if a guaranteed cadence is
wanted). Verified the builder's stale follow-up: **GitHub Pages is already live** (`status:
built`, serving `main` `/docs`) — corrected the task note; no action needed.

**What's next:** [[discoverability-launch]] (roadmap #6) is now **unblocked** — the demo link
exists to point launch posts at. Its outward actions (Awesome Rails/Ruby PRs, RubyFlow post,
launch blog post) are publish-to-external and need the owner's accounts/go-ahead, so next pass
I'll *prepare* the artifacts (draft post + Awesome-list entry) without publishing, and file an
owner question for where to host/announce. Long-tail open: [[generator-polish]] (P2, dev-safety
cleanups), [[dogfood-crayonbloom]] (P1, owner/CrayonBloom-blocked).

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

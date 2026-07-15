# CafeCar — Owner Decisions

Verified owner (jeff@yak.sh) decisions, newest first. Each: date, verbatim decision, where applied.
Written BEFORE acting (see AGENTS.md "Owner feedback: write it down FIRST").

---

## 2026-07-15 — Convention over configuration: agonize over zero config, never break the host app, no unexpected behavior, still feel like Rails (VERIFIED in-session, jeff@yak.sh)

Verbatim owner direction:

> another goal of the project: convention over configuration. we really want to agonize over not
> making the user edit a bunch of config. at the same time, we don't want to break their app by
> installing the gem, and we don't want unexpected behavior. CafeCar should be a substantial upgrade,
> but still feel like using rails.

**What this decides / where applied (sharpens the existing "convention over configuration / no config
DSLs" line in CLAUDE.md with four concrete acceptance criteria):**
- **Agonize over zero user config.** Every feature should work from conventions by default; making the
  user edit config is a design failure to be fought, not a shipped requirement. (Reinforces: no config
  DSLs — configure via views/partials/policies/locales.)
- **Installing the gem must NOT break the host app.** Adding cafe_car to a Gemfile must be safe/inert
  by default — no route hijacking, no monkey-patch that changes existing behavior, no forced load-order
  surprises. The engine "mounts almost nothing."
- **No unexpected behavior.** Nothing surprising or implicit that a Rails dev wouldn't predict.
- **Substantial upgrade, still feels like Rails.** Big capability gain, but the ergonomics stay
  idiomatic Rails — not a second framework to learn.
- **This is the acceptance bar for the API audit** (`audit-cafecar-public-apis-...`): flag anything
  that forces config, could break/alter a host app on install, behaves surprisingly, or feels un-Rails.

## 2026-07-15 — CafeCar is composable tools for EVERYWHERE (admin + customer-facing), docs/skills must teach it with zero steering; audit the APIs (VERIFIED in-session, jeff@yak.sh)

Context: CrayonBloom is integrating the latest CafeCar. Owner's direction to CrayonBloom (quoted to
us verbatim), then his direct ask to the CafeCar operator:

> "get the latest CafeCar integrated along with it's new skills, docs, etc. Then upgrade CrayonBloom's
> product to adhere to its principles. Email CafeCar operator with any questions or feedback."
>
> "correction: CafeCar::Engine mounts almost nothing; just basically a style-guide. But CafeCar has
> many other modules that *should* be used for non-admin as much as you can. Read the docs for the new
> version and it should become more clear. Basically, there's a split in our app: admin vs
> customer-facing. But that split does not map onto CafeCar vs home-roll. CafeCar is a set of tools
> that should be used where-ever they are valuable and save code. It happens that the tools all work
> together to make admin interfaces dead-simple, but they can and should be used for everything where
> possible."
>
> "last thing: I expect all consumers of CafeCar to use it how i've described, so if the docs/skills
> don't make that apparent, *email that feedback to the CafeCar Operator*. We want CafeCar to be
> drop-in and any agents automatically know how and when to use it. This should delete a ton of code.
> And if you or your coders run into any bugs, mistakes, unexpected behavior, email that feedback to
> CafeCar!"
>
> "So, same goes for you. Go through the docs and skills and ensure that an agent or human picking up
> the gem for the first time will get this view right off the bat with no steering from me. And do an
> audit of any APIs for any unexpected behavior or any APIs that need refactoring."

**What this decides / where applied:**
- **Positioning is sharpened, not changed.** CafeCar = a set of composable Rails tools used *wherever
  they save code*, admin AND customer-facing. `CafeCar::Engine` mounts "almost nothing; just basically
  a style-guide" — the value is the OTHER modules (presenters, form builders, helpers, components,
  policies, etc.) usable everywhere. The admin/customer split does NOT map onto CafeCar/home-roll.
- **Docs + skills must be self-teaching with ZERO steering.** A first-time agent or human must get the
  "composable-tools-for-everything" view immediately — so they "automatically know how and when to use
  it" and it "deletes a ton of code." If the docs/skills don't make this apparent, that's a bug to fix.
- **API audit.** Audit CafeCar's public APIs/modules for unexpected behavior and anything needing
  refactoring — through the lens of drop-in-ness and use-everywhere ergonomics.
- **We are the feedback sink.** CrayonBloom (and other consumers) will email the CafeCar operator with
  questions, bugs, and doc gaps found during integration. Treat that inbound as first-class signal.

## 2026-07-15 — v2 logo round 1 feedback: transparent cutouts, NOT iOS-style icons (VERIFIED email, jeff@yak.sh)

Verbatim owner reply to the round-1 logo demo page:

> 1 and 3 are best, do 4 more of cafe car interiors. But one problem: these are iOS icons, not OS X
> style. They should have transparent backgrounds, no square shape. Just the cup and just the car
> interior, no gloss and no borders. So, 4 more cafe car interior attempts; all different. And then
> redo 1. Coffee cup without the border and gloss.

**What this decides / where applied (logo task `imagegen-a-cafecar-logo-v2-...`):**
- **Winners:** directions 1 (coffee cup) and 3 (window-seat interior) are the keepers. Directions 2
  (rail car) and 4 (badge) are OUT.
- **Aesthetic correction — this reinterprets "OS X / Panic style":** the round-1 marks are iOS-style
  app icons (glossy, square, bordered). WRONG. Want **transparent backgrounds, no square shape, no
  gloss, no borders** — just the subject as a **cutout** (the cup itself; the car interior itself),
  not an icon-in-a-tile.
- **Round 2 deliverable:** (a) **4 more cafe-car-interior attempts, all different**; (b) **redo
  direction 1 (coffee cup)** without the border and gloss. All transparent cutouts. Send an updated
  demo page.

## 2026-07-13 — Fix audit P0/P1 findings, release v0.3.1, then continue down the audit (VERIFIED in-session, jeff@yak.sh)

Verbatim owner direction after reviewing the private project audit:

> fix the P0s and P1s and push a v0.3.1  then work down the other issues. everything looks good

**What this decides / where applied:**
- **Security work preempts feature work.** Fix every P0/P1 from the 2026-07-13 private audit:
  production debug disclosure, unrestricted association JSON, unchecked index-view lookup,
  association policy-scope enforcement (read and write), dashboard authorization/scoping, and
  release-tag verification.
- **Release the fixes as v0.3.1.** Add exploit regression tests, run the full check suite, update
  CHANGELOG/version/lockfile together, push main, then push `v0.3.1` through the existing
  approval-gated Trusted Publishing workflow.
- **Continue through the remaining audit findings after the security release**, in severity order,
  with focused verified commits. The private audit remains off the public repository until the
  vulnerabilities are patched; public release notes should describe impact without publishing a
  weaponized recipe.

---

## 2026-07-10 — OG social card approved ("ship it"); NEW v2 logo brief (VERIFIED email, jeff@yak.sh)

Verbatim owner reply to the 7/10 digest:

> social card is good. ship it. and then for a v2: let's imagegen a logo.
>
> different sizes of it should have different complexities. it should have OSX circa '10
> aesthetics: think Coda, Transit, or other Panic logos. It should probably be a train's cafe
> car with coffee or something.
>
> come up with a handful and then send me a demo page

**What this decides / where applied:**
- **OG social card: APPROVED for the live swap.** The draft (`~/shared/cafe_car/og-card-draft-v1.png`,
  regenerable HTML/CSS + Playwright render at `docs/og/`, commit b96f320) is signed off. Unblocks
  `regenerate-og-social-card-png`: render the final PNG, place at `docs/images/og-card.png`, reconcile
  `_config.yml` og:image dims (declared 1731x909 → actual render 2400x1260), commit. Execute on the
  next proactive pass (email = inbox, not an on-the-spot trigger).
- **NEW v2 — imagegen a CafeCar logo (filed as its own task).** Brief: **Panic-style OSX-circa-'10
  aesthetic** (reference Coda, Transit, other Panic app icons); subject is **a train's cafe car with
  coffee**; **complexity scales with size** (a detailed large mark, simplified small/favicon variants).
  Deliverable: **generate a HANDFUL of options and send the owner a demo page** (drafts are the
  reversible side — iterate freely and share; do NOT bake any into canonical brand assets until the
  owner picks + signs off). Discretionary creative work → GREEN, next proactive pass.

---

## 2026-07-10 — Keep handrolled components; presenter/model-based partial overrides; benchmarks in the release cycle (VERIFIED email, jeff@yak.sh)

Verbatim owner reply to the component-primitive research digest:

> sounds good. let's keep our direction. the pain is mostly just the maintenance
> complexity of home-rolling components. one problem i have with partial overriding that
> makes me want to rebuild it: we want partials to override based on the *model* or
> *presenter*, not the *controller*. So if i render an author form on the article page, it
> should use `views/users/_form.html`, not `articles/_form.html`. i'm not sure the best way
> to solve that; i think we'll have to build something that breaks rails conventions, because
> i just think the rails conventions are basically wrong here. i think if we ensure that
> partials are tied to *presenters* (or builders), we can have a pretty simple system that
> isn't too complicated to grasp and the rails override convention becomes more inspiration
> than implementation. do some ideation here on the best path forward.
>
> re perf: let's add benchmarking to our standard release cycle. rendering a page, component,
> presenter, etc. That way we can at least try to improve and can prevent major regressions.

**What this decides / where applied:**
- **Direction ratified: KEEP the handrolled components + partials.** Do NOT adopt ViewComponent/Phlex
  wholesale. Closes the component-primitive question in favor of Option A (keep-as-is). The real pain
  is maintenance complexity of home-rolling, not the render model.
- **NEW design direction — partial overrides should resolve by the MODEL/PRESENTER, not the
  controller.** Rendering an author form on the article page should look up `views/users/_form`, not
  `articles/_form`. Owner is willing to **break Rails' controller-based view-lookup convention**;
  wants partials **tied to presenters (or builders)** so the Rails override convention becomes
  "inspiration, not implementation." Owner explicitly requested **ideation on the best path forward**
  (filed as a task; NOT a rushed build). NOTE: this reframes the "moat" — the override story stays,
  but keyed on presenter/model identity rather than controller path.
- **Benchmarking becomes part of the STANDARD release cycle** — measure render time for page /
  component / presenter, to catch regressions and drive improvement. Forward-looking (v0.3.0 shipped
  without it). Extends/absorbs the one-off `spike-benchmark-component-render` P3. Filed as a task.
- Do NOT re-describe CafeCar as a generator/admin tool; direction unchanged otherwise.

---

## 2026-07-10 — Publish new gem versions after major upgrades (VERIFIED in-session, jeff@yak.sh)

Verbatim owner message (mid-turn, during the "close all the tickets you can" batch):

> (don't forget to publish new versions of the gem after major upgrades)

**What this decides / where applied:**
- **A meaningful batch of feature work warrants a version release, not just an unbounded
  `[Unreleased]` CHANGELOG.** After a major upgrade lands green on main, cut the release: bump
  `lib/cafe_car/version.rb` (semver — new features = minor bump), move the `[Unreleased]` CHANGELOG
  entries under the new version heading, commit the regenerated `Gemfile.lock` in the SAME commit
  (frozen bundler in CI/release aborts on a stale lock — see memory), and push a `v<version>` tag.
- **The tag triggers the Trusted-Publishing release workflow** (`.github/workflows/release.yml`,
  OIDC); the owner approves the publish in the GitHub UI. No manual `gem push`, no long-lived key.
- **Applied this pass:** the custom-actions completion + form-input components + filtering
  hardening batch is such an upgrade → cut **v0.3.0** once all four builders land green.

---

## 2026-07-09 — Follow-ups on actions/docs/refactor + "always localize" (VERIFIED email, jeff@yak.sh)

Verbatim owner reply to the "[CafeCar] shipped" digest:

> 1. it should run over the scope currently being viewed. maybe make that clear with a count hint
> "Publish all 21". localize. in fact, remember to always localize text so it can be easily
> customized by apps
> 2. go ahead and do the docs. that should always go with a build. an undocumented feature doesn't
> exist.
>
> yep, let's do the attributes refactor too

**What this decides / where applied:**
- **Collection actions run over the CURRENTLY-VIEWED scope, not the whole policy scope.** Reverses
  the earlier "whole policy scope" default (Pass 117, commit 3f7965d). The `collection_action`
  endpoint must apply the active dot-query filters (thread `parsed_params`/`permitted_filter_params`
  into the scope) so "Publish all" acts on exactly what the user is looking at. Surface the reach
  with a **localized count hint** on the button — e.g. `Publish all 21` — where 21 is the filtered
  count. Copy comes from a locale key (customizable), not hardcoded.
- **Docs ship WITH the build — "an undocumented feature doesn't exist."** A standing rule: every
  feature build includes its docs (README + agent-skill) in the same effort, not as a deferred
  follow-up. Do the custom-actions docs and the filter-panel docs now.
- **Attributes refactor greenlit** (the P1 `refactor *_attributes into policy.attributes.listable`
  from the 07-09 big project). Proceed.
- **Always localize.** Reinforces the existing CLAUDE.md rule ("all UI copy goes in locales, no
  hardcoded strings"): every user-facing string is a locale key so host apps can customize it. Apply
  to the count hint and everywhere.

---

## 2026-07-09 — In-session directive: build actions + filter polish + demo/README/tooltip (VERIFIED, jeff@yak.sh)

Verbatim owner message, in-session this date:

> let's build actions. and add some actions to the demo: e.g. Publish on articles.
>
> and also go on filter polish. the association select should support multi-select and should
> match dark-mode. the search bar needs style fixes to match other inputs and should be put in
> the filters card. "Filters" card title can be removed.
>
> the readme should probably link to the shorter https://cafe-car-demo.up.railway.app
>
> also, if you can work out why tooltips don't appear below the "view" buttons on the index page,
> i'd be grateful. they appear right on top right now and it drives me bonkers. i spent a long
> time trying to fix; it might be a browser bug or i might just not grok the anchor css api. email
> me if you figure it out.

**What this decides / where applied:**
- **Custom actions** (member + collection) is the feature to build now — the roadmap item from the
  07-09 big project. Member = single record (`publish!`), collection = a scope; declared on the
  policy, forwarded to model bang methods by default, rendered as buttons/links on show + index.
  Distinct from the existing `permitted_bulk_actions` (checkbox-selected batch). Demo: add a
  **Publish member action** to articles (model already has `publish!` + `publish?`).
- **Filter polish:** association select → **multi-select** + **dark-mode** styling; **search bar**
  restyled to match other inputs and **moved into the filters card**; **"Filters" card title
  removed**.
- **README:** link the shorter demo URL `https://cafe-car-demo.up.railway.app`.
- **Tooltip bug:** on the index page, view-button tooltips render on top of / overlapping the
  buttons instead of below. Investigate the anchor-positioning CSS (`tooltips.css`); email the
  owner the diagnosis + fix.

---

## 2026-07-09 — BIG PROJECT: agent-facing docs + provisioning · policy-driven filtering · custom actions · Attributes refactor (P1)

Four VERIFIED owner (jeff@yak.sh) messages, in-session this date. A single approved roadmap
(plan `dapper-zooming-raccoon`). Verbatim:

**(1) The project + filtering + "use fable":**

> i need you to plan and execute a big project to document CafeCar in a way that agents can use to
> write better code that uses CafeCar. Use fable. If CafeCar is installed in a rails app, the agents
> should naturally reach for it. They should know about all of CafeCar's features and understand
> what the defaults provide and clear paths to accomplishing different tasks, customizations, and
> overrides to those defaults. I'm seeing many custom-admin pages in CrayonBloom, for example. They
> should just be making a cafe_car controller, adding a few buttons to the grid cards and calling it
> a day. As a result, the experience is really bad: no turbo streams, no standardized query params,
> no linking to other objects, etc. … [cover: Components + CSS + theming; navigation/sidebar;
> presenters; partial overrides views/<controller> vs views/application; pundit/scopes; built-in
> turbo-streams + syncing; forms/form_builder]. everything should be documented in a way that humans
> benefit, too. … While we're here, filtering is a huge missing feature. the filterable fields
> should be driven from pundit polices. Every index page should have auto-configured and enumerated
> filters that the user can select to generate dot query params in the URL. Scopes, enums, search,
> assocation selection should all be built in. As a second milestone, we should support deeply nested
> joins and queries and take full advantage of the dot query system.

**(2) Custom actions:**

> another important missing feature: custom "actions". basically, controllers should define actions
> (and probably even declaring them forwards them from model bang methods by default: `publish!`,
> etc.) and they can be called via things like a "Publish" button or link. They should then be listed
> in the policy and they show up on show + index pages. There should be actions both on a scope (set
> of records) and on the record instance (single record)

**(3) Attributes refactor (file a P1):**

> btw, one mid-term refactoring goal is to refactor all these *_attributes on policies. probably have
> a nested class like Scope called Attributes. so you can do `policy.attributes.listable`. i think
> this can pull in the other attribute stuff that i think is a bit messy. create a P1 to refactor all
> that into something cleaner.

**(4) Delivery mechanism + sequencing (answers to my two plan questions):**

> [doc delivery] append to AGENTS is a good idea. I'd love maybe a generator install rake task that
> installs skills, etc. I could imagine a url that you can paste to your agent to have them configure
> their own memories and skills, etc. Maybe do some research on what other projects have done?
>
> [sequencing] Features now, refactor folds them in.

**What this decides / where applied:**
- **Primary deliverable is agent-facing docs + host provisioning** (not just prose). Root cause is
  *discoverability, not coverage* — the README is already thorough but never reaches an agent's
  context inside a host app. Ship, per prior-art research (Supabase/Stripe/Prisma pattern): an
  **Agent Skill** (`skills/cafe_car/SKILL.md`, open standard) + a **Rails generator**
  (`cafe_car:agents`) that installs it into the host's `.claude/skills/` (+ `.agents/` mirror) and
  inserts an **idempotent, marker-delimited AGENTS.md block** (never blind-append); plus `llms.txt`
  + a GitMCP README pointer + a `.claude-plugin/marketplace.json`. Skills teach **conventions, not
  snapshots**, and must read like a human wrote them (LLM-slop context files measurably *hurt*).
  Skip Cursor/Copilot-specific rule files — every tool now reads AGENTS.md.
- **Filtering M1:** policy-driven, auto-enumerated filter UI (`permitted_filters` + `permitted_scopes`
  on the policy, following the `permitted_bulk_actions` precedent) with typed controls
  (enum/association/scope/boolean/range/search) that write dot-query params. The dot-query ENGINE
  already exists — this is a UI + policy layer on top. **M2:** deeply nested association joins (the
  engine already filters nested assocs recursively via `activerecord_where_assoc`; expose + gate +
  document). Enum reflection (`defined_enums`) is the one genuine greenfield primitive. Also *gate*
  URL-invokable scopes (today any public scope is filterable).
- **Custom actions:** `permitted_actions` on the policy → member (single-record) + collection (set)
  actions; declaring forwards to the model bang method by default (`publish` → `record.publish!`),
  gated by `name?`, rendered as buttons/links on show + index/grid, labels/styles from the locale.
  The collection half already exists as `#batch`/`permitted_bulk_actions`; member actions are new.
- **Attributes refactor → P1, mid-term:** nested `Attributes` class like `Scope`
  (`policy.attributes.listable`); one sweep folds ALL `permitted_*` / `*_attributes` into it. Filed
  as P1. **Sequencing:** features (filters, actions) ship FIRST as flat `permitted_*` methods; the
  refactor folds them in afterward.
- **Model:** build + doc-writing runs on **Fable**.
- **Where applied:** DECISIONS recorded first (this entry); board epics + atomic subtasks filed
  (Track A–E, Track E as P1); plan `dapper-zooming-raccoon` approved. Build kicked off M1a (skill +
  provisioning generator) on Fable.

---

## 2026-07-07 — Research directive: evaluate replacing the handrolled component primitive (ViewComponent / Phlex / others)

Owner (jeff@yak.sh) email, `auth=VERIFIED(yak.sh)`, replying to the README-positioning ship mail.
Verbatim:

> can you research if we should be using a different component primitive? ViewComponent, Phlex,
> etc. Right now, we've handrolled our own, but it's almost certainly slower than templates and
> these libraries. It's likely that our Components are still a level above these libraries. Or are
> there others we should consider? partials have really become a head-ache, but what i like about
> them is that cafe_car can build using the components and then the application can override the
> templates and classes that need changes for their specific use-case. can we get that with VC or
> phlex? are these or other libraries getting adoption? do some research and work out some possible
> paths forward.

**What this directs (research, not yet a decision):**
- Evaluate whether CafeCar's handrolled component layer should sit on a library primitive
  (ViewComponent, Phlex, or others worth considering) — performance vs templates is the suspicion.
- Owner's hypothesis: CafeCar's Components are a level ABOVE these libraries (they could be the
  rendering substrate underneath, not a replacement for our layer).
- Hard requirement to preserve: **the override story** — CafeCar builds with components, the host
  application overrides the templates/classes it needs for its use-case. Any candidate must
  support that (or the path must show how).
- Also wants: adoption/momentum data on these libraries.
- Deliverable: research + worked-out possible paths forward (a report with options, not a ship).

**Where applied:** board task `research-component-primitive-viewcomponent-phlex-paths-forward`
(filed 2026-07-07, picked up on the next budgeted pass).

---

## 2026-07-04 — PostHog demo follow-ups: test_mode not env guard · send current_user · demo fixes · investigate missing request context

Owner (jeff@yak.sh) email 12:12 ET, replying to the Pass-96 "PostHog live on the demo" ship mail
(owner also confirmed in-session: "check your email. we'll do some work today"). Verbatim:

> no need for this guard since the test/dummy is not shipped with the gem.
> https://github.com/craft-concept/cafe_car/blob/main/test/dummy/config/initializers/posthog.rb#L10
>
> instead, use `config.test_mode = !Rails.env.production?`. this way the posthog code is still
> tested to run properly in dev, but doesn't report anything.
>
> also, there *is* a current_user and we should enable the feature to send it. file a separate
> ticket to ensure sessions and login work on the demo.
>
> can we fix all the broken images on the demo? also there should be users seeded.
>
> also, something appears to be wrong with posthog-rails' capturing of request context. it has not
> showed up in any of our logged exceptions. the PR that added it is relatively recent and is here:
> https://github.com/PostHog/posthog-ruby/pull/144/changes can you investigate what's going on
> here? why aren't we getting any request details (current_url, params, etc) on our reported
> exceptions. afterwards, we'll open a ticket or PR to fix, since i don't think we're using it
> wrong, but maybe we are. please investigate!

**What this decides / where applied:**
- **PostHog initializer:** drop the production-only guard in
  `test/dummy/config/initializers/posthog.rb` — the dummy isn't shipped with the gem. Use
  `config.test_mode = !Rails.env.production?` so the PostHog path runs in dev/test without
  reporting.
- **Identify users:** enable sending `current_user` to PostHog. Separate ticket: make sessions +
  login work on the demo.
- **Demo content:** fix all broken images; seed users.
- **Investigate posthog-ruby request context** (PostHog/posthog-ruby#144): exceptions in project
  496903 carry no current_url/params. Find out whether it's our usage or an upstream bug; then
  open an upstream issue/PR.

---

## 2026-07-03 — Reworks APPROVED with corrections: policy is the source of truth; + component-styling rule

Two VERIFIED owner (jeff@yak.sh) emails, 19:32 + 19:42 ET, replying to the Pass-94 proposal and the
Pass-92 UI-fixes digest. Verbatim:

**(1) Proposal review** (19:32, Re: proposal: dashboards + bulk actions via views/partials):

> very close! `def permitted_bulk_actions` should be the source-of-truth and the bulk_actions
> partial should loop that list by default. Non-built-in bulk_actions should "just work". Probably
> configure the button styles in the locale with some defaults (delete -> danger, etc). Metrics
> should also be driven by the policy. permitted_metrics. Don't forget to put all copy in locales.
> this is a general rule: the policy declares what's editable and the UI renders that by default.
> so the policy is the source of truth unless explicitly overridden by the user.
>
> also, the charts are very very narrow and very very tall. did you custom build them or use a gem?

**(2) UI-fixes feedback** (19:42, Re: shipped: styled checkboxes + batch-destroy button):

> You have to use component styling because if you don't, it breaks checkboxes in the UI that are
> used for other purposes Layout_Menu, etc. No more styles outside of components.
> The search bar is now very wide (so also is the "enter demo" button). the search button should
> have Button styling and should be grouped with the bar. the download csv button should not be
> grouped with the view selector buttons. the checkboxes look great otherwise. nicely done!

**What this decides / where applied:**
- **Both reworks are GO** with corrections — tasks unblocked, spec updated:
  - `def permitted_bulk_actions` (policy) is the **source of truth**; the `_bulk_actions` partial
    **loops that list by default**. Overriding the partial is the explicit opt-out. Non-built-in
    (host-defined) bulk actions must "just work" with zero registration beyond policy + model method.
  - Button styles come from the **locale**, with shipped defaults (`destroy` → danger, etc.).
  - Dashboards: **`permitted_metrics` on the policy drives metrics** the same way.
  - **All copy in locales** — no hardcoded UI strings.
  - **General principle (bake it in):** the policy declares what's permitted/editable and the UI
    renders that by default; the policy is the source of truth unless explicitly overridden by the
    host in a view. Answers Pass-94 question 1: policy method, not partial-only.
- **Component styling is mandatory — "No more styles outside of components."** The Pass-92 global
  checkbox styles broke checkboxes used elsewhere (Layout Menu etc.). Rule baked into AGENTS.md.
- **New P1 UI fixes (demo index toolbar):** search bar + "enter demo" button too wide; search
  button needs Button styling grouped with the bar; Download CSV button must NOT be grouped with
  the view-selector buttons; move stray non-component styles into components.
- **Charts too narrow + too tall** — fix default chart aspect ratio. (Answer to his question:
  custom-built, `lib/cafe_car/chart_builder.rb`, no gem — replied by email.)

---

## 2026-07-03 — PRODUCT DIRECTION: composable view extension · NO config DSLs · GHA-release publish

Three VERIFIED owner (jeff@yak.sh) emails this evening (18:54–19:04 ET), relayed urgently by holdco
(the after-hours hold would otherwise have sat on them until Monday). Verbatim:

**(1) No config DSLs** (18:54): "Absolutely no config DSLs for dashboards or bulk actions. Like
everything else they should be configured via views and partials."

**(2) What CafeCar IS** (19:03): "CafeCar is not an admin framework or a CRUS [CRUD] generator. It
is an extension of rails' view and controller layer. Convention over configuration. Btw, it is very
confusing (read: wrong) to say that CafeCar is a view 'generator'. Rails already has generators. It
makes it seem as if cafe car is spitting out files, when it does the opposite: it lets you delete
them. cafe car is a composable view extension for rails. It so happens to make admin UI (and now
also dashboards!) very easy, but should be thought of as just how I think rails should work out of
the box."

**(3) Routing + publish** (19:04): "And for #2. Don't tell me, tell CrayonBloom. #3. We publish via
GitHub action releases not gem push." (#2 = my 7/3 digest's CrayonBloom-dogfood-requirements ask →
route to crayonbloom@bot.yak.sh myself. #3 = publish mechanism → GitHub Action releases / Trusted
Publishing (PR #13), NOT manual gem push.)

**What this decides / where applied:**
- **NO config DSLs — configure via views & partials.** The `CafeCar.dashboard do…end` DSL (Pass 90)
  and the `CafeCar.bulk_action` registry are AGAINST direction. Rework BOTH to views/partials. The
  owner still WANTS dashboards ("now also dashboards!") — rework the *mechanism*, keep the feature.
  Filed as rework tasks (this pass). Also re-examine `CafeCar.theme=` against this principle.
- **Positioning.** CafeCar = "a composable view extension for Rails" — an extension of Rails' view +
  controller layer, convention over configuration. NOT an admin framework, NOT a CRUD generator, NOT
  a view "generator" (it lets you *delete* view files, not spit them out). It happens to make admin
  UI + dashboards easy; think of it as how Rails should work out of the box. **Purge "generator /
  admin framework / CRUD generator / auto-generate" framing from README + gemspec + all copy** (voice
  gate). Baked into CLAUDE.md this pass; README reframe filed.
- **Publish** = GitHub Action releases (Trusted Publishing / PR #13), NOT manual gem push. Corrected
  CLAUDE.md "Deploy model." No owner API key needed — cut a `v*` tag, the workflow publishes.
- Emailed crayonbloom@bot.yak.sh for the back-office requirements (directive 2).

---

## 2026-07-03 — Demo auto-deploy fixed via Railway GitHub App (owner); drop the workflow plan

> "the owner installed the Railway GitHub App connection and enabled auto-deploy on cafe-car-demo
> today (2026-07-03), gated on CI ... drop the planned railway-up workflow + RAILWAY_TOKEN secret
> — push/merge to main is now the whole deploy story."

**Source: homelab (VERIFIED internal, auth=VERIFIED(bot.yak.sh)), relaying owner action.** Root
cause of the 137-commit-stale demo (Pass 88 catch) was `NO_INSTALLATION` — the Railway GitHub App
was never installed. The owner installed it + enabled CI-gated auto-deploy directly.

**What this decides:** push/merge to `main` is now the entire deploy path for the demo — **no**
`railway up` CI step, **no** `RAILWAY_TOKEN` secret. My Pass 89 plan to wire that workflow is
**obsolete — do not build it.** Task `root-cause-fix-demo-auto-deploy-was-137-commits-stale`
closed as resolved (root cause fixed, not worked around). Verified from Railway deploy history:
`d35c042` deployed SUCCESS 21:17 UTC; `4164966` queued behind the CI gate.

---

## 2026-07-03 — YES to dashboards; add a chart tab to the index page

> "Yeah we should totally have dashboards! Good idea. Let's also add a chart tab to the index page;
> in addition to grid/table view. Should be a good gem for that. Probably allow selecting any date
> time column as x axis"

**VERIFIED owner (jeff@yak.sh), email reply to the 7/3 bulk-actions digest.** Answers my open #8
positioning question and adds a concrete feature request.

**What this decides:**
- **#8 dashboard positioning → RESOLVED: YES.** CafeCar grows beyond a pure CRUD generator to
  include dashboards. No longer a parked decision — it's a greenlit roadmap item.
- **New feature: a chart tab on the index page**, a third view alongside grid/table. Selectable
  **datetime column as the x-axis**. The owner sees charting as a differentiator ("should be a good
  gem for that").

**Where applied:** this pass — recorded here, filed as two tasks (chart tab P1, dashboards P1),
and started the best-specified increment (the index chart tab) with a builder. Dashboards scoped
next (charts are the reusable primitive a dashboard composes, so build charts first).

---

## 2026-07-02 — develop the gem; stop defaulting to "hold"

> "why do you think you shouldn't be developing the gem? it's not even close to done"

**Verbatim, in-session, from the owner.** A direct correction of my recent "healthy hold" passes.

**Root cause of the bad behavior:** I conflated *"the filed `tasks/` backlog has no unblocked
items"* with *"there's nothing to develop."* For a v0.1.x gem those are not the same — I drained a
finite task list, then idled, instead of doing the maintainer's core job of **generating** the next
development work. I mis-weighted ideation/feature work as discretionary auto-deferring background,
when for an incomplete product it's the primary work.

**Correction (standing, applies every pass from now on):**
- **A drained `tasks/` backlog is NOT a hold.** When the filed backlog empties, the job is to
  generate the next real development work (features, robustness, DX, edge cases, adopter-scenario
  gaps), file it, and build it — not to conclude "nothing to do."
- **Product development is default-on, not discretionary.** Building the gem toward genuinely-done
  is core work, gated only by the budget signal (GREEN → develop), not by whether a ticket already
  exists.
- The gem is early and incomplete; treat completeness as an active goal with an owned roadmap, not
  a finished state to protect.

**Where applied:** this pass — kicked off an honest completeness/gap audit of the gem, turning the
result into a real prioritized development backlog and starting execution. Behavior change recorded
here so a cleared context can't revert me to the passive default.

---

## 2026-07-03 — PostHog on the demo app (owner-directed; back-filled by dream 2026-07-04)

> "set up posthog on the demo app for rails logs, error-tracking, analytics, etc. I added a CafeCar
> org to posthog for you."

**Standing scope rule that fell out of it (pass 88):** instrumentation is demo-only — PostHog
config/JS lives entirely in `test/dummy`, production-gated. **Zero analytics code in the shipped
gem** (gemspec, engine views, layouts). Org/project ids + client token: see the operator's
`demo-posthog` memory; project 496903.

---

## 2026-06-26 — cnc cut wholesale; lint → rubocop-rails-omakase; sessions optional+finished; homepage on GitHub Pages (back-filled by dream 2026-07-04)

Owner ratified (pass 6, pre-dating this file): drop the `cnc` runtime dependency entirely (inline
the two core-ext methods), switch lint to `rubocop-rails-omakase`, make sessions support optional
AND finish it, and host the project homepage on GitHub Pages. All four shipped in late June; the
lint/no-cnc/Pages choices remain standing policy. Recorded here so the decision ledger covers the
pre-2026-07-02 era.

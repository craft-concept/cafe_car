# Questions

Owner-facing channel for decisions and blockers.

## ⚙️ Activate `railway.toml` config-as-code on the demo service (owner/dashboard) — 2026-06-28

The repo now has a `railway.toml` pinning the demo to the Dockerfile builder
(`builder = "DOCKERFILE"` + `startCommand = "bin/railway-demo"`) — the durable fix for the
Railpack-vs-Dockerfile builder instability that was booting the demo from the wrong path. **But
Railway is not reading it:** the deploy metadata shows `configFile: null`, so the toml is currently
inert (config-as-code is disabled for this service and can't be enabled via API). Homelab pinned the
**equivalent settings at the service level** (build.dockerfilePath + deploy.startCommand), so the
demo is stable on the Dockerfile *now* — but the toml won't be the source of truth until someone
**points the service's config file at `railway.toml` in the Railway dashboard** (Service → Settings →
Config-as-code). One-time owner/dashboard action; not blocking — the service-level pin already holds.

## 🖼️ OG/social card ready — one-time GitHub Settings upload (owner) — 2026-06-27

A brand-grounded OG/social card now lives at `docs/images/og-card.png` (committed `51ef230`) so
shared repo and launch-post links render a professional preview. **One-time owner step:** GitHub's
social preview can't be set via the API — upload it manually at **Settings → General → Social
preview** on `craft-concept/cafe_car`. (Launch-post `og:image` can reference the raw URL:
`https://raw.githubusercontent.com/craft-concept/cafe_car/main/docs/images/og-card.png`.) Not
blocking; the asset is ready whenever you do the upload.

## 📦 v0.2.0 is ready to publish — needs the RubyGems key (owner) — 2026-06-27

`version.rb` is already at **0.2.0** and **33 commits** have landed since the published
`v0.1.2` — a substantial, release-worthy bundle: opt-in sessions/auth, the `cafe_car` macro
rename, **CSV export**, **turnkey keyword search**, nested-attributes forms, the Pundit-
verification footgun fix, and security hardening. CI green, `rake` green, demo healthy, docs +
`CHANGELOG [Unreleased]` current.

**Everything is prepped except the publish itself, which needs your RubyGems API key.** Give me
the go-ahead (and the key available to the env) and I'll finalize the CHANGELOG `[Unreleased] →
[0.2.0]` with the date, tag `v0.2.0`, and `gem push`. Until then it sits release-ready on main.

## ℹ️ FYI — scoping Pundit verification to the cafe_car macro (behavior change) — 2026-06-27

While debugging the demo's password-route 500s I hit an adoption footgun: `CafeCar::Controller`
forces `verify_authorized`/`verify_policy_scoped` on **every** including controller, so a plain
controller (Rails-generated passwords/sessions, etc.) 500s unless it manually skips. I'm fixing
it by moving the verification into the `cafe_car` macro so it's opt-in with the auto-CRUD (task
`scope-pundit-verification-to-cafe-car`). This only relaxes surprising enforcement on
non-cafe_car controllers; cafe_car resource controllers still authorize + verify. **Flag if you
intended the global-enforcement design** — it's a one-commit revert. Not blocking; proceeding.

## 🚧 Demo doesn't auto-deploy — Railway GitHub App not installed (needs owner) — 2026-06-27

The live demo (Railway service `cafe-car-demo`) **does not auto-deploy on push to `main`**.
Root cause (via Railway agent): `NO_INSTALLATION` — the **Railway GitHub App is not installed
on `craft-concept/cafe_car`**, so there's no webhook from GitHub to Railway. The demo sat on a
stale 01:45 deploy through 5 pushes until I triggered a manual deploy.

**Owner action:** install the Railway GitHub App on the repo
(https://github.com/apps/railway), then enable auto-deploy on the service. One-time setup.
**Until then I must trigger demo deploys manually** (Railway MCP `deploy`/railway-agent) after
pushing demo-affecting changes. Recorded in memory so I don't forget to redeploy.

## 🐶 Dogfooding CrayonBloom — RESOLVED 2026-06-27 (mechanism defined)

**No longer needs an owner answer here.** A holdco board task
(`dogfood-milestone-build-cafecar-to-meet-the-crayonbloom-back`) defined the flow: the
**CrayonBloom operator files individual requirement tasks** to my board (`venture=cafe_car`)
and **I build them** in priority order. The loop now polls the board for incoming requirement
tasks each cycle. The questions below are retained for reference, but the CrayonBloom operator
(not the owner) is the spec author — they'll answer implicitly by filing concrete tasks.

---

## 🐶 Dogfooding CrayonBloom — 2026-06-26 (original questions, now routed via the board)

`dogfood-crayonbloom` (P1) is the back-office milestone. I've mapped CafeCar's current
capabilities against generic back-office needs (see the task's "Back-office readiness map") —
the ✅ rows already cover a clients/invoices-style admin, proven on the live demo. To turn the
remaining deltas into real Eng tasks (or confirm none are needed), I need CrayonBloom specifics:

- **(1) Repo?** Is there a CrayonBloom codebase I can read to map requirements concretely
  (where is it / can I have access)? Existing Rails app to bolt CafeCar onto, or greenfield?
- **(2) Resources** — what does the back-office manage? (products/coloring books, orders,
  customers, generated assets, print/fulfillment, subscriptions…?)
- **(3) Users & roles** — single admin, staff tiers, read-only? (CafeCar does the auth/policy
  enforcement; the role model is yours to define.)
- **(4) Must-have capabilities beyond CRUD** — which of these are required: **CSV/data export**,
  **bulk actions**, **keyword search**, **dashboard/metrics**? (These are the current gaps; I'll
  file Eng tasks only for the ones you need.)
- **(5) Integrations** the back-office must surface (Stripe/payments, print vendor, email)?

Answer any subset and I'll convert the deltas into scoped Eng tasks. Until then the milestone is
`blocked_on: user` on requirements.

## 🚀 Launch go/no-go — 2026-06-26 (needs owner)

Discoverability assets are drafted and committed under `marketing/` (launch post,
Awesome-list entries, RubyFlow + Ruby Toolbox blurbs, and an ordered
`SUBMISSION-CHECKLIST.md`). Nothing has been published. Before firing it off I need:

- **(a) Go-ahead to submit** — confirm you want to launch now (CI green, v1 audited,
  live demo up). This unblocks every external action in the checklist.
- **(b) Where to host the blog post** — do you have a blog / Medium / dev.to? The post
  needs a canonical home before it can be linked from RubyFlow/HN/Reddit. (No URL,
  no link to share.)
- **(c) Which channels** — confirm the announce surfaces you want: r/rails, r/ruby,
  Hacker News "Show HN", Ruby Discord/Slack, X/Mastodon. I'll only prep what you greenlight.
- **(d) Demo can take a spike** — confirm the Railway demo
  (cafe-car-demo-production.up.railway.app) is OK to take an HN/Reddit traffic spike
  (and that periodic data reset is acceptable for public eyes).

Owner-only because each external submission needs your accounts/credentials and your
name on the post. See `marketing/SUBMISSION-CHECKLIST.md` for the exact steps.

## ✅ Resolved by owner — 2026-06-26

- **cnc:** **Cut wholesale.** Inline the two methods CafeCar uses, remove the dependency
  entirely (not even dev). → `cut-cnc-switch-to-omakase`.
- **Rubocop config:** Stop forking via cnc; **use the `rubocop-rails-omakase` template**
  instead. → folded into `cut-cnc-switch-to-omakase`.
- **Sessions/auth:** **Make it optional AND finish it** — decouple so CRUD-only hosts don't
  500, and complete the feature (engine routes, configurable host user, docs, tests).
  → `sessions-optional-and-finish`.
- **Homepage:** Repoint the gem `homepage` to **GitHub Pages** (and stand up a Pages site so
  it resolves). → handled in `cut-cnc-switch-to-omakase` (URL) + docs follow-up (the site).

The original analysis below is retained for reference.

---

## cnc dependency — keep or drop

### What cnc provides
`cnc` (github.com/craft-concept/cnc, public RubyGem v0.1.13, MIT, authored by
the repo owner) is a "build things the Craft & Concept way" toolbox: CLI
scaffolding (Thor), a Rails app generator, a migration renamer, and a set of
core-extension monkeypatches. It does not block installation. Its own runtime
dependencies are notable: `activesupport, listen, rack, rubocop,
rubocop-minitest, rubocop-rails-omakase, thor, zeitwerk` — i.e. it drags
**rubocop, thor, and listen into every app that installs CafeCar**, since cnc
is declared as a runtime `add_dependency` in `cafe_car.gemspec`.

### Where CafeCar uses it
Two distinct couplings:

1. **Runtime (real, but tiny).** `lib/cafe_car/core_ext.rb` does
   `require "cnc/core_ext"`, which monkeypatches `Hash`, `Module`, `Symbol`,
   `Object`, and `URI`. CafeCar runtime code actually calls only two
   cnc-provided methods:
   - `Hash#extract_if!` — `lib/cafe_car/component.rb:64`,
     `lib/cafe_car/helpers.rb:28`
   - `Module#define_class` — `lib/cafe_car/component.rb:22`,
     `lib/cafe_car/ui.rb:8`

   (Other `.camelize` / `.underscore` calls in the repo are on Strings and come
   from ActiveSupport, not cnc.) Both methods are ~10 lines each and are not
   defined anywhere in CafeCar — they only exist in cnc.

2. **Dev/lint only.** `.rubocop.yml` does `inherit_gem: cnc: rubocop.yml`, so
   CafeCar inherits cnc's shared lint config. This is purely a development-time
   concern; production apps never load it.

### Recommendation: INLINE, then demote cnc to a dev dependency
The runtime "need" is two short monkeypatch methods. CafeCar already owns a
core-ext directory (`lib/cafe_car/core_ext/array.rb` defines `Array#extract!`
and `Array#overlap` in exactly this style), so the natural home for
`Hash#extract_if!` and `Module#define_class` is there. Inlining them:

- removes `rubocop`, `thor`, and `listen` from every production CafeCar install
  (a runtime dep should not ship lint tooling),
- drops `require "cnc/core_ext"` from `lib/cafe_car/core_ext.rb`,
- lets cnc move from `add_dependency` to `add_development_dependency` purely to
  keep the `.rubocop.yml` config inheritance for contributors.

I did **not** recommend a plain KEEP: a runtime dependency that exists only to
supply ~20 lines of monkeypatch — while forcing rubocop into production — is
poor weight-for-value. I also did **not** recommend a full DROP: keeping cnc as
a dev dependency preserves the shared lint config across the owner's gems at
zero production cost.

### Decision needed from the owner
1. OK to inline `Hash#extract_if!` and `Module#define_class` into
   `lib/cafe_car/core_ext/` and move cnc to a development dependency? (default
   recommendation)
2. Or do you prefer to keep cnc as a runtime dependency on purpose — treating it
   as a deliberately shared C&C runtime toolbox across your gems (accepting
   rubocop/thor/listen in production)?
3. If we demote to dev-only: keep inheriting `.rubocop.yml` from cnc, or inline
   the rubocop config too and drop cnc entirely?

## Sessions/auth — ship as v1 feature, or label experimental?

The feature audit (`V1_SCOPE.md`) found CafeCar ships an auth/sessions stack
(`app/models/cafe_car/session.rb`, an `Authentication` concern, `Current`) that is
**half-baked**: it has no session routes in the engine, hardcodes a host `User` model it
never provides, is undocumented, and — most importantly — `Authentication` is force-coupled
into every CRUD controller, creating a **latent 500** for any host that uses CafeCar for
plain CRUD without a sessions table.

There's a clear **bug fix** I'll do regardless (decouple `Authentication` from the
mandatory `Controller` include so CRUD-only hosts can't 500). But the **product question**
is yours:

1. **Label sessions experimental for v1** (recommended) — decouple it, document it as
   opt-in/experimental, defer "finish it" past 1.0. Fastest path to a credible v1.
2. **Finish sessions for v1** — wire engine routes, make the host `User` coupling
   configurable, document it, test it. More work; delays v1.
3. **Cut it entirely** — remove the sessions stack from the gem for now.

Which direction? This gates `fix-halfbaked-features` and the v1 launch scope.

## Minor: gem `homepage` returns 404

`cafe_car.gemspec` sets `homepage = "https://concept.love/cafe_car"`, which currently
**404s** (the domain resolves, the path doesn't). A published gem with a dead homepage
link is a small trust ding on its RubyGems page. The gem already exposes
`source_code_uri` → the GitHub repo, so it's not catastrophic. Options:
1. Stand up `concept.love/cafe_car` (branding home — your call).
2. Repoint `homepage` to the GitHub repo (or the RubyGems page) for now.

I left it as-is rather than guess at your branding. Say the word and I'll repoint it.

# Questions

Owner-facing channel for decisions and blockers.

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

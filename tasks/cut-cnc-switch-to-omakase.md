---
id: cut-cnc-switch-to-omakase
title: Cut cnc wholesale; switch rubocop to rails-omakase; homepage to GH Pages
priority: P1
status: wip
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Owner ratified (QUESTIONS.md): **cut cnc entirely**, use **`rubocop-rails-omakase`** instead
of inheriting cnc's lint config, and repoint the gem `homepage` to **GitHub Pages**.

cnc supplies BOTH the two runtime monkeypatches AND the `.rubocop.yml` config, so these move
together in one change:

1. **Inline the runtime methods.** CafeCar uses exactly `Hash#extract_if!` and
   `Module#define_class` (verify with a grep for cnc-provided methods before removing). Add
   `lib/cafe_car/core_ext/hash.rb` and `lib/cafe_car/core_ext/module.rb` (matching the style
   of the existing `array.rb`), then drop `require "cnc/core_ext"` from
   `lib/cafe_car/core_ext.rb` (it already globs `core_ext/*.rb`).
2. **Remove the dependency.** Delete `spec.add_dependency "cnc"` from `cafe_car.gemspec` and
   `gem "cnc"` from the `Gemfile`. cnc is gone from runtime AND dev.
3. **Rubocop → omakase.** Replace `.rubocop.yml`'s `inherit_gem: cnc: rubocop.yml` with
   `inherit_gem: { rubocop-rails-omakase: rubocop.yml }`; add `gem "rubocop-rails-omakase"`
   to the Gemfile dev group. Run `rubocop -A` to settle the new baseline and hand-fix the
   rest until `rake` is green (omakase's ruleset differs from cnc's — expect some churn).
4. **Homepage.** Set gemspec `homepage` to `https://craft-concept.github.io/cafe_car`
   (standing up the actual Pages site is a separate docs follow-up; see
   [[docs-site-live-demo]]).
5. `rake` green; the dummy app still boots (it relies on `define_class` via `ui`/`component`).

[[cnc-keep-or-drop]] holds the investigation. This is the execution.

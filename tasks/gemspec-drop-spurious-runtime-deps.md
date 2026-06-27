---
id: gemspec-drop-spurious-runtime-deps
title: Drop the spurious web-console runtime dep from the gemspec
priority: P1
status: done
domain: Eng
created: 2026-06-27
---

Pre-v0.2.0 release hygiene. A `gem build` dry-run (pass 24) prompted an audit of
`cafe_car.gemspec`'s runtime dependencies. Initial read flagged `faker` AND `web-console` as
unused — but the builder's verification grep corrected the faker half (see below). Net: only
**web-console** is spurious.

- **`web-console (>= 4.0)` — REMOVE.** No usage anywhere in `lib/`, `app/`, or `config/`. The
  `app.console` block in `engine.rb:130` is Rails' core console hook, unrelated to the
  web-console gem. web-console is a development/debugging gem and a **production footgun**
  (interactive console). It is already in the root `Gemfile` (line 21) for the dummy app's dev
  env, so the test suite does not depend on the gemspec providing it — removal is provably safe.

- **`faker (>= 3.0)` — KEEP.** My first pass wrongly claimed faker was unused (the grep pattern
  `Faker\.` missed the `Faker::` scope-resolution calls). faker is a **genuine runtime
  dependency**: `app/controllers/cafe_car/examples_controller.rb:2` does `require "faker"`, and
  `app/views/cafe_car/examples/ui/_alert.html.haml` calls `Faker::Lorem`. That controller is
  drawn unconditionally (`config/routes.rb` → `/components`) and ships in the gem (`spec.files`
  includes `app/**/*`). Removing faker would 500 the `/components` page in a host's production
  (eager-load `require "faker"` → LoadError). The test suite would NOT catch it because faker is
  in the root Gemfile. Lesson: the grep verification gate is the real safety check, not `rake`.

## Scope (corrected — web-console only)
- Remove ONLY the `web-console` `add_dependency` line from `cafe_car.gemspec`. Leave faker,
  rouge, and all others untouched.
- Run the full `rake` (rubocop + test + brakeman); confirm green.
- Run `gem build cafe_car.gemspec`; confirm it still builds `cafe_car-0.2.0`. (The generic
  open-ended `>=` warnings remain for all `>=` deps — out of scope here.)
- CHANGELOG `[Unreleased]`: note the unused web-console runtime dep was dropped.
- Commit + push.

## Follow-up filed
The `/components` styleguide route pulling faker into every host's **production** bundle is a
separate, deeper hygiene question — tracked in [[components-styleguide-faker-in-prod]].

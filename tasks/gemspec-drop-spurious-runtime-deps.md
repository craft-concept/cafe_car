---
id: gemspec-drop-spurious-runtime-deps
title: Drop spurious runtime deps (faker, web-console) from the gemspec
priority: P1
status: in_progress
domain: Eng
created: 2026-06-27
---

Pre-v0.2.0 release hygiene. `gem build cafe_car.gemspec` warns about an open-ended
`faker (>= 3.0)` runtime dependency. Investigation (pass 24) found two runtime deps in
`cafe_car.gemspec` that the gem's own code never uses:

- **`faker (>= 3.0)`** — no `Faker.` usage anywhere in `lib/` or `app/`. It is only
  *injected into the host app's Gemfile* by the install generator
  (`lib/generators/cafe_car/install/install_generator.rb:10`). Declaring it as a runtime
  dependency of cafe_car forces faker into every host's **production** bundle and causes the
  `gem build` warning.
- **`web-console (>= 4.0)`** — no usage anywhere in `lib/` or `app/`. The `app.console` block
  in `engine.rb:130` is Rails' core console hook, unrelated to the web-console gem. web-console
  is a development/debugging gem and a **production footgun** (interactive console). It is
  already in the root `Gemfile` (line 21) for the dummy app's dev env.

Both are also already present in the root `Gemfile` (faker line 16, web-console line 21), so the
test/dummy suite does **not** depend on the gemspec providing them — removing them from the
gemspec is safe.

## Scope
- Remove the `faker` and `web-console` `add_dependency` lines from `cafe_car.gemspec`.
- Keep `rouge` — it is genuinely used at runtime (`app/presenters/cafe_car/code_presenter.rb`,
  `hash_presenter.rb`).
- Run the full `rake` (rubocop + test + brakeman); confirm green.
- Run `gem build cafe_car.gemspec`; confirm the open-ended-dependency warning is gone and the
  gem still builds as `cafe_car-0.2.0`.
- Note in the CHANGELOG `[Unreleased]` that two unused runtime deps were dropped (smaller
  install footprint, no web-console in production).
- Commit + push.

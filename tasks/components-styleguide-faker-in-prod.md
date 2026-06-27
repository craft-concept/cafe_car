---
id: components-styleguide-faker-in-prod
title: /components styleguide forces faker into hosts' production bundle
priority: P2
status: open
domain: Eng
created: 2026-06-27
---

Surfaced during the pass-24 gemspec audit ([[gemspec-drop-spurious-runtime-deps]]).

`faker` is a hard runtime dependency of cafe_car solely because the shipped, unconditionally
routed `/components` UI styleguide uses it for sample copy:
- `app/controllers/cafe_car/examples_controller.rb:2` — `require "faker"`
- `app/views/cafe_car/examples/ui/_alert.html.haml` — `Faker::Lorem.paragraph` / `.sentence`
- `config/routes.rb` draws `get "components", to: "examples#index"` for every host that mounts
  the engine; `spec.files` ships `app/**/*`.

So every app that installs cafe_car pulls faker into its **production** bundle just to render a
component showcase — and exposes a `/components` page in production. That's questionable for two
reasons: (1) a faker dependency in production purely for a styleguide, and (2) shipping a
dev-oriented component gallery as a live production route.

## Options to evaluate (not yet decided)
1. **De-faker the styleguide** — replace `Faker::Lorem` calls with static sample strings in the
   examples partials. Then drop `faker` from the gemspec runtime deps entirely. Smallest prod
   footprint; styleguide still works. Likely the cleanest.
2. **Mount `/components` dev-only** — gate the examples routes behind `Rails.env.development?`
   (or a config flag). Keeps faker but only loads it in dev; still need faker out of the
   runtime deps for that to help, so combine with (1) or make faker a dev dep + conditional
   require.
3. **Leave as-is** — accept faker in production as the cost of a built-in styleguide.

Recommendation leans (1): static sample copy removes the faker runtime dep with no UX loss and
no behavior change to host apps. Decide before the next release after v0.2.0 (not a v0.2.0
blocker — the web-console drop is the only release-gating piece).

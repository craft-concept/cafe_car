---
id: fix-broken-resource-generator-onboarding
title: Fix broken cafe_car:resource onboarding path (500s out of the box)
priority: P1
status: done
domain: Eng
created: 2026-07-01
---

**Outcome (2026-06-30): fixed and verified end-to-end. All three diagnoses held exactly**
(each reproduced with a failing test first):
- **A** — `app/controllers/concerns/cafe_car/authentication.rb`: `current_session` now
  `return unless sessions_available?` (and `current_user` uses `current_session&.user`), so a
  CRUD-only host with no `sessions` table gets a nil user (→ 403) instead of a 500. Reproduced
  by stubbing `sessions_available?` false + `CafeCar::Session.new` raising `no such table`.
- **B** — `lib/generators/cafe_car/resource/resource_generator.rb`: `create_policy` now forwards
  `*field_names` (bare names split from the `field:type` args) to `cafe_car:policy`, so the
  policy lists real attributes instead of falling back to the fragile introspection path.
- **C** — `lib/generators/cafe_car/policy/policy_generator.rb`: `ModelInfo.new(model: model_class)`
  (was positional → `ArgumentError`); the placeholder guard now keys off `attribute_names.blank?`
  (not `model_class.nil?`), so forwarded fields render even when the model isn't a loaded constant
  mid-run. Introspection lives in a new `model_fields` helper guarded on `model_class.nil?`.

**Verified path (fresh Rails 8.1 app, local gem via `path:`, NO sessions/User setup):**
`bundle install` → `cafe_car:install` → `cafe_car:resource Product name:string price:decimal
description:text` → `db:migrate` → `rails s` → `GET /products` = **200** (real admin table,
"New Product" button), `GET /products/new` = **200**, zero 500s. Generated
`product_policy.rb` `permitted_attributes` = `[:name, :price, :description]`.

CI gap closed: `resource_generator_test.rb` now renders a resource-generated policy end-to-end
(fields forwarded, no placeholder) and asserts the field-forwarding delegation;
`policy_generator_test.rb` adds an introspection-path case. `[Unreleased]` CHANGELOG entry added.
Follow-up (out of scope here): README Installation §line 104 still lists `cnc` as a required gem
— stale since `cnc` was cut; worth a small doc fix.

**The gem's advertised primary onboarding flow is broken.** A stranger who `bundle add`s
CafeCar and follows the README "Quick Start: Generate a Complete Resource" section hits a 500,
not a working admin. This is a direct hit to the adoption/trust barrier (CafeCar's core growth
constraint per `AGENTS.md`) and blocks the `readme-60-second-try-block` idea. Diagnosed during
that task's verification against a fresh Rails 8.1 app (see `tasks/readme-60-second-try-block.md`
for the full write-up).

**Three root-caused bugs (all diagnosed with file:line evidence — VERIFY each with a failing
test before fixing; do not take the diagnosis on faith):**

- **A — `current_user` ignores the opt-in-sessions gate.** `current_user → current_session →
  build_session` (in `app/controllers/concerns/cafe_car/authentication.rb`) unconditionally does
  `CafeCar::Session.new` (needs the `sessions` table) and `.user` (needs a `User` model). Pundit's
  default `pundit_user` is `current_user`, so *every* authorized action 500s in a fresh app until
  `cafe_car:sessions` is run + migrated **and** a `User` model exists. This contradicts the
  README's "plain CRUD works with no login → 403 not 500" promise. The concern already has a
  `sessions_available?` gate — it just isn't consulted in `current_session`. Fix: consult it.
- **B — `cafe_car:resource` drops the field list.** `resource_generator.rb` invokes
  `cafe_car:policy` without forwarding the `name:string price:decimal` args, forcing the broken
  introspection path.
- **C — policy introspection is broken.** `policy_generator.rb:25` calls
  `CafeCar[:ModelInfo].new(model_class)` positionally, but `ModelInfo#initialize` requires the
  `model:` keyword → `ArgumentError` when the model exists; when the model can't be constantized
  mid-run it writes the literal placeholder `permitted_attributes [:create_model_first_to_generate_attributes]`.
- **Net effect:** `rails g cafe_car:resource Product name:string price:decimal` always produces a
  broken policy, so `/products` 500s until hand-edited.

**CI gap to close:** `test/lib/generators/cafe_car/policy_generator_test.rb` only exercises the
explicit-fields path and never renders a resource-generated policy, so it misses B+C. Add a test
that runs `cafe_car:resource` end-to-end (or at least boots a resource-generated policy) so this
can't regress silently.

**Acceptance:**
- Failing test reproduces each bug first, then goes green.
- On a fresh Rails app: `bundle add cafe_car` → `rails g cafe_car:install` → `rails g model
  Product name:string price:decimal` → `rails g cafe_car:resource Product name:string
  price:decimal` → `db:migrate` → `rails s` → `/products` returns **200 with a working admin
  index**, with NO sessions/User setup (plain CRUD works; unauthorized → 403 not 500).
- README "Quick Start: Generate a Complete Resource" section (~lines 113-136) now matches
  reality; fix the docs only if the corrected code still diverges from them.
- `bundle exec rake` green (rubocop + test + brakeman). This is a released-gem behavior fix →
  note it in `CHANGELOG.md` under `[Unreleased]`.

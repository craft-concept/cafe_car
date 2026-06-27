---
id: generator-polish
title: Generator polish — destination/namespace/delegation consistency
priority: P2
status: done
domain: Eng
created: 2026-06-26
---

Three non-blocking issues the generator tests surfaced (no functional adopter-facing bug;
all confirmed working in a real host app). Cleanup for consistency and dev-safety.

1. **`resource` pollutes the engine repo when run from the engine root.** Its inline
   sub-generators (`model`/`controller`/`policy`) use `Dir.pwd`, ignoring the destination —
   running `rails g cafe_car:resource` in the engine dir mutates `config/routes.rb` and
   creates stray `app/`/`db/`/`test/` files. Harmless for adopters (they run it in their
   host app), but a footgun for contributors. Make the inline delegation honor a destination.
2. **`notes` shells out** to `rails generate cafe_car:policy/controller` as a subprocess
   (no `inline: true`), unlike `resource`. Works in a host (has `bin/rails`) but is
   inconsistent and aborts in the test harness. Align with `resource`'s inline style.
3. **`policy` double-namespaces** namespaced policies — `admin/payment` emits
   `module Admin; class Admin::PaymentPolicy`. Loads fine, just redundant; the controller
   generator already avoids this by overriding `class_name`. Apply the same to policy.

## Outcome

All three fixed at the root; full `rake` green (rubocop 200 files / 0 offenses, brakeman
0 warnings) and the test suite grew from 99 → **102 runs / 316 assertions / 0 failures**.

1. **Destination leak.** Added a shared inline `generate` helper to `CafeCar::Generators`
   (`lib/cafe_car/generators.rb`) that delegates via `Rails::Generators.invoke(..., destination_root:
   destination_root)` instead of Rails' built-in `generate`, which recomputes the destination from
   `Rails::Command.root` and leaks writes into the engine repo. `ResourceGenerator` now includes
   `CafeCar::Generators` and drops the now-redundant `inline: true`. Test: a real inline run asserts
   the controller/policy land in the destination and the engine's own `config/routes.rb` is untouched.
2. **`notes` subprocess shell-out.** Now goes through the same inline helper (it included
   `CafeCar::Generators` already), so the Note policy/controller are generated inline — consistent
   with `resource` and runnable in the harness. Test: asserts both delegated files land in the
   destination.
3. **Policy double-namespace.** `PolicyGenerator` now overrides `class_name = file_name.camelize`
   (mirroring the controller generator) so `module_namespacing` supplies the single `module Admin`
   wrapper, and `model_class` looks the model up by `file_path` to keep namespaced lookups working.
   Test: a namespaced policy emits `class PaymentPolicy` with no redundant `Admin::` prefix.

Note: the resource test can't assert the delegated *model* — that's a stock Rails `hook_for :orm`
pass-through that no-ops in the dummy app (no ORM configured); the controller + policy delegations
prove destination-honoring. Test stubs now capture/stub on a subclass rather than prepending the
shared generator, so the stub no longer leaks into the inline tests.

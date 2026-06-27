---
id: generator-polish
title: Generator polish — destination/namespace/delegation consistency
priority: P2
status: open
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

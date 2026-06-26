---
id: fix-halfbaked-features
title: Fix the half-baked features (auth/sessions first)
priority: P1
status: open
domain: Eng
created: 2026-06-26
---

Stabilize the features the audit flags as broken/incomplete. Stability is half of the
"ship + trust" mission — a feature that 500s is worse than a missing one.

Authoritative list is now in `V1_SCOPE.md` (8 IN / 7 NEEDS-WORK / 2 OUT). Concrete
must-fix items from the audit, highest leverage first:

1. **Latent 500 / auth coupling (top priority).** `Authentication` is force-included into
   every CRUD `Controller` (`app/.../controller.rb:8`), so a host app that uses CafeCar
   for plain CRUD but has no sessions table is one unauthorized request from a 500.
   Decouple `Authentication` from the mandatory `Controller` include. Pairs with the
   product decision on whether sessions ships as experimental (see QUESTIONS.md).
2. **`sessions` generator** lies in its USAGE (claims model + policy; creates only a
   migration). Fix it to match, or cut the generator.
3. **README false advertising** (also tracked in [[readme-badges-accuracy]]):
   `f.field(:price).errors` → `error` (singular); `normalized_sort_key()` →
   `normalize_sort_key`; document or caveat the undocumented auth/sessions/Current stack;
   fix the install gem-list.
4. **Missing generator tests** — `install`/`resource`/`controller`/`notes` are uncovered
   (install/notes test files are empty stubs). The Gemfile-mutating `install` generator is
   the riskiest untested path.
5. Add tests for advertised-but-unverified paths: `turbo_stream` + `json` responses, a
   direct presenter render, and a sort/paginate test.

- Every fix lands with a regression test. `rake` green before push.
- Anything that can't reach v1 quality gets cut/labeled experimental (per V1_SCOPE), not
  shipped broken.

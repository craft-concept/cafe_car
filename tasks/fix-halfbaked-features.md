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

1. **Latent 500 / auth coupling (top priority).** `Controller` unconditionally
   `include`s `Authentication` (`lib/cafe_car/controller.rb:8`), and crucially
   `render_unauthorized` (controller.rb:174) calls the concern's `authenticated?` /
   `request_authentication`; the latter `redirect_to new_session_path` — **a route the
   engine never defines**. So any Pundit denial in a CRUD-only host (no sessions
   table/route, e.g. a signed-out user hitting a `false` policy) 500s. NOTE: the fix is
   NOT just removing the include — `render_unauthorized` depends on those methods. The
   **direction-independent** fix is graceful degradation: respond 403 (head :forbidden /
   generic unauthorized) when the login route + Session model aren't configured, and only
   redirect-to-login when they are. This removes the 500 regardless of the sessions
   product decision (see QUESTIONS.md). Land with a test simulating a CRUD-only host
   (dummy app controller without sessions infra) that gets 403, not 500.
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

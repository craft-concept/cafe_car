---
id: scope-pundit-verification-to-cafe-car
title: Scope Pundit verify_authorized/policy_scoped to the cafe_car macro (fix footgun)
priority: P1
status: done
domain: Eng
created: '2026-06-27'
updated: '2026-06-27'
---

**Adoption footgun, found live on the demo (2026-06-27).** `CafeCar::Controller`'s `included`
block registers `after_action :verify_authorized, :verify_policy_scoped` (`lib/cafe_car/controller.rb`
~line 81). This forces Pundit verification on **every** controller that includes the concern —
not just `cafe_car`-managed resource controllers. The natural adoption path (`include
CafeCar::Controller` in `ApplicationController`) therefore makes every plain controller
(Rails-generated `PasswordsController`/`SessionsController`, custom pages, health checks) 500 on
`Pundit::PolicyScopingNotPerformedError` unless it manually calls `skip_authorization` /
`skip_policy_scope`. The dummy app papers over this with per-controller skips in Pages/Denials/
Passwords — symptom patches, not a fix. This directly contradicts the "trust" mission: a new
adopter wiring CafeCar in the obvious way gets mysterious 500s.

## Fix

Move the two verifications OUT of the `included do` block and INTO the `cafe_car` class method
(alongside `before_action :authorize!`, ~line 43), so verification is **opt-in with the auto-CRUD
it belongs to**: a controller that calls `cafe_car` gets `authorize!` + the verify guarantees;
a plain controller that merely includes `CafeCar::Controller` does not.

- This only RELAXES surprising enforcement on non-`cafe_car` controllers; it does not weaken
  anything for `cafe_car` resource controllers (they still authorize + verify).
- After the move, the dummy's `skip_authorization`/`skip_policy_scope` in `PagesController`,
  `DenialsController`, and `PasswordsController` become redundant — **remove them** to prove the
  footgun is gone (keep `DenialsController` raising `Pundit::NotAuthorizedError` so its
  `render_unauthorized` test still exercises that path).
- Add a regression test: a controller that `include`s `CafeCar::Controller` but does NOT call
  `cafe_car` (e.g. a minimal test controller, or assert via Pages) returns 2xx without skips.
- Keep all existing authorization tests green (admin/* resource controllers still verify).
- `CHANGELOG.md` `[Unreleased]`: document as a fix (verification now scoped to `cafe_car`).

## Acceptance

- A plain controller including `CafeCar::Controller` without `cafe_car` no longer 500s on Pundit
  verification (no skips needed).
- `cafe_car` resource controllers still enforce authorization + verification (existing tests pass).
- Dummy's redundant skips removed; Denials still tests `render_unauthorized`.
- `rake` green; committed + pushed. (Behavior change — owner FYI noted in QUESTIONS.md.)

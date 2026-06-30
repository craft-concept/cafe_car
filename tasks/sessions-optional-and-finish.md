---
id: sessions-optional-and-finish
title: Make sessions optional AND finish the feature
priority: P1
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Owner ratified (2026-06-26): sessions/auth should be **both optional and finished** — a
CRUD-only host must never 500 for lack of sessions, and the sessions feature should be a
real, documented, tested capability for hosts that want it.

**Part A — make it optional (removes the latent 500).**
- `Controller` unconditionally `include`s `Authentication` (`lib/cafe_car/controller.rb:8`),
  and `render_unauthorized` (controller.rb:174) calls `authenticated?` /
  `request_authentication`, the latter redirecting to `new_session_path` — a route the
  engine never defines. Any Pundit denial in a CRUD-only host 500s.
- Make the unauthorized path degrade gracefully: respond **403** (head :forbidden / generic
  unauthorized view) when the sessions/login infrastructure isn't present, and only
  redirect-to-login when it is. CRUD without sessions must work.
- Regression test: a dummy controller with no sessions infra returns 403, not 500, on denial.

**Part B — finish sessions for hosts that opt in.**
- Define the engine session routes (so `new_session_path` etc. resolve) and wire the
  `sessions_controller` / views coherently.
- Make the host `User` coupling configurable instead of hardcoded
  (`app/models/cafe_car/session.rb:14`) — a config point for the user class/lookup.
- Fix the `sessions` generator + its lying USAGE (claims model + policy; creates only a
  migration) so opting in is a real, documented flow.
- Document the sessions/auth/Current stack in the README (currently undocumented).
- Tests covering login, logout, authenticated vs. signed-out access, and the opt-in wiring.

Supersedes item 1 of [[fix-halfbaked-features]]. Land in reviewable chunks; `rake` green
throughout. Sequence AFTER [[cut-cnc-switch-to-omakase]] (which resets the lint baseline).

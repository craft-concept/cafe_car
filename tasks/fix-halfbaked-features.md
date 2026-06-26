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

- Depends on [[feature-audit-v1-scope]] for the authoritative list.
- Known hot spots from git history: sessions/auth (unpersisted-session 500s, signed-out
  user scope, singular-resource login URLs). Verify these are fully fixed with tests.
- Every fix lands with a regression test. `rake` green before push.
- Anything that can't reach v1 quality gets cut from scope (documented in V1_SCOPE), not
  shipped broken.

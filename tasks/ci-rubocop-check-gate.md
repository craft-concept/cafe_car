---
id: ci-rubocop-check-gate
title: Make CI rubocop a check-only gate, stop auto-PR noise
priority: P1
status: done
domain: Ops
created: '2026-06-26'
updated: '2026-06-26'
---

The CI `rubocop` job runs `bin/rubocop -Af github` then opens a "Rubocop Autocorrections
on main" PR every push (currently sitting as an `action_required` PR). Autocorrecting in
CI and spamming PRs looks amateurish on a public repo and hides real lint failures
(the job passes even when code is unformatted).

- Change the job to a check-only gate: `bin/rubocop -f github` (no `-A`, no
  create-pull-request step) so unformatted code fails CI honestly.
- Close/clean the stale auto-generated rubocop PR(s) and the `rubocop/main` branch.
- Keep formatting enforced locally via `rake` (already green).
- While here: CI uses deprecated Node20 actions — bump checkout/setup actions if cheap.

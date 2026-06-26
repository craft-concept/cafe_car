---
id: feature-audit-v1-scope
title: Audit feature completeness and define v1 scope
priority: P1
status: wip
domain: Product
created: '2026-06-26'
updated: '2026-06-26'
---

Inventory every advertised feature in `README.md` against what actually works, so we
can declare an honest v1 surface and stop shipping half-baked features.

- Cross-check each README feature (CRUD generation, presenters, components, forms,
  filtering/sorting, auth/sessions, generators) against the engine code + test coverage.
- Recent churn signals instability around **sessions/auth** (commits: "fix 500s on
  unpersisted-session show", "fix singular-resource URLs so session login form renders",
  "refactor and start on sessions") — treat auth as the prime suspect for "half-baked."
- Output: a `V1_SCOPE.md` (or section) listing IN / OUT / NEEDS-WORK per feature, with
  rationale. Feeds [[fix-halfbaked-features]] and the README accuracy pass.
- This is the gate before any launch push — don't market features that 500.

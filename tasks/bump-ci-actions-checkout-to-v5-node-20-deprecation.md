---
id: bump-ci-actions-checkout-to-v5-node-20-deprecation
title: Bump CI actions/checkout to v5 (Node 20 deprecation)
priority: P2
status: open
domain: Eng
created: '2026-06-26'
---

CI logs a deprecation warning: `actions/checkout@v4` targets Node.js 20, which GitHub
Actions runners now force onto Node 24 (deprecation of Node 20 on runners). Not a failure
yet, but it will break when Node 20 support is removed.

- Bump `actions/checkout@v4` → `@v5` (and any other `@v*` actions on Node 20) in
  `.github/workflows/ci.yml` and `copilot-setup-steps.yml`.
- Acceptance: CI green with no Node-version deprecation warnings in the logs.

---
id: oss-hygiene-docs
title: Add CONTRIBUTING, CODE_OF_CONDUCT, SECURITY
priority: P1
status: open
domain: Ops
created: 2026-06-26
---

Roadmap item #4 (community files). These are the table-stakes trust signals GitHub and
adopters look for; their absence reads as "unmaintained."

- `CONTRIBUTING.md` — dev setup (`bin/setup`, `rake`), how to run the dummy app/tests,
  PR expectations, the one-file-per-task backlog convention.
- `CODE_OF_CONDUCT.md` — Contributor Covenant, owner email as contact (jeff@yak.sh).
- `SECURITY.md` — supported versions + private disclosure address. Coordinate with the
  brakeman posture already in CI.
- Expand the thin README "Contributing" section to link these.

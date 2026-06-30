---
id: cnc-keep-or-drop
title: Investigate cnc dependency, recommend keep or drop
priority: P1
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Owner asked for a keep-or-drop recommendation on the `cnc` dependency.

- **New finding:** `cnc` is NOT private — it's a public RubyGems package (v0.1.13, ~4.5k
  downloads, MIT), authored by the owner (Jeff Peterson), source at
  github.com/craft-concept/cnc. The AGENTS.md "private cnc" premise is stale. So it does
  NOT block installation; the question is whether the coupling is worth it.
- Document exactly what CafeCar uses from cnc. Known: `.rubocop.yml` does
  `inherit_gem: cnc: rubocop.yml` (shared lint config); the `--ensure-latest` binstub
  convention likely came from cnc too. Audit `lib/`/`app/` for `Cnc`/`cnc` usage.
- Recommend: keep (document the coupling), inline the small bits we use, or drop. Weigh
  adoption friction (extra transitive dep, owner-controlled) vs. maintenance cost.
- Deliver the recommendation to the owner via email + the task board, not just a reply.

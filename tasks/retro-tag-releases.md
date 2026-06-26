---
id: retro-tag-releases
title: Retroactively tag v0.1.1 and v0.1.2 releases
priority: P2
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

The repo has no git tags, so the new CHANGELOG.md compare/release links (and the
gemspec's release provenance) don't resolve. Tag the already-published versions
retroactively at their release commits.

- Identify the commits for v0.1.1 and v0.1.2 (git history; the "v 0.1.2" commit on
  2026-02-28 is a marker). Create annotated tags `v0.1.1` / `v0.1.2` and push them.
- Tagging is NOT a gem publish — safe to do autonomously. Do NOT `gem push`.
- Verify CHANGELOG links resolve afterward. Feeds [[gemspec-release-polish]].

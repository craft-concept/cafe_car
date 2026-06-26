---
id: changelog
title: Write CHANGELOG.md
priority: P1
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Roadmap item #1. A changelog is a baseline trust signal and a release prerequisite.

- Adopt Keep a Changelog format + semver. Reconstruct entries from git history for
  released versions (0.1.x) and an `[Unreleased]` section for current work.
- Point `cafe_car.gemspec` `changelog_uri` at the file (currently points at repo root).
- Keep it current as part of every future release (see [[gemspec-release-polish]]).

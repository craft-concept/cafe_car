---
id: release-workflow-auto-create-github-release
title: Release workflow — auto-create the GitHub release (action alone doesn't)
priority: P3
status: open
domain: Ops
created: 2026-07-01
---

**Recurring manual step to eliminate.** On the v0.2.1 release (pass 69), `rubygems/release-gem@v1`
published the gem to RubyGems fine, but did **not** create the GitHub release object — even though
`.github/workflows/release.yml` grants `contents: write` "to create the GitHub release". The
conductor had to cut `v0.2.1` by hand with `gh release create ... --latest`. Same gap will recur on
v0.2.2 / v0.3.0 unless the workflow is fixed.

## Fix

Add an explicit GitHub-release step to `release.yml` after the publish step. Options:
- Pass the action's own release input if `rubygems/release-gem@v1` supports one (check its README /
  `action.yml` — it may need `github-release: true` or similar, or it may only create one when the
  tag/context matches a specific shape).
- Or add a dedicated step: `softprops/action-gh-release@v2` (or `gh release create "$GITHUB_REF_NAME"`)
  that pulls notes from the matching `CHANGELOG.md` section and sets `--latest`.

## Verify

- Cut a throwaway pre-release tag on a scratch branch (or dry-run) and confirm a GitHub release
  object appears automatically with the right notes + `latest` flag.
- Keep it idempotent-ish: don't fail the whole release job if the release already exists (manual
  fallback shouldn't break a re-run).

Low priority — manual `gh release create` is a working fallback, and releases are infrequent. But
it's cheap hygiene that removes a manual, forgettable step from every future release.

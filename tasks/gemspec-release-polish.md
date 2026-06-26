---
id: gemspec-release-polish
title: Polish gemspec for a credible v0.1.2 release
priority: P1
status: wip
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Roadmap item #2 prep (everything short of the actual `gem push`, which needs the owner's
RubyGems key). Make the gem metadata release-grade.

- `summary` and `description` are both "Rails UI and admin panels." — write a real,
  distinct description that sells the auto-CRUD value prop.
- `changelog_uri` should point at CHANGELOG.md (see [[changelog]]); verify `homepage`
  (`https://concept.love/cafe_car`) resolves or update it.
- Add `required_ruby_version` / metadata (`rubygems_mfa_required`, `bug_tracker_uri`).
- Pin/declare dependency version floors instead of bare `add_dependency "rails"` etc.,
  so resolution is predictable for adopters. Coordinate with [[cnc-keep-or-drop]].
- Do NOT bump the version or publish without explicit owner approval — flag readiness via
  QUESTIONS.md / holdco.

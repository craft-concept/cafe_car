---
id: readme-remove-stale-cnc-install-dep
title: README Installation still lists cnc as a required gem (stale — cnc was cut)
priority: P2
status: done
domain: Eng
created: '2026-07-01'
updated: '2026-06-30'
---

The README **Installation** section (~line 104) still lists `cnc` as a required dependency.
This is stale: `cnc` was cut wholesale (see [[cut-cnc-switch-to-omakase]]) — it's no longer a
runtime or dev dependency. A reader following the install steps adds an unnecessary gem, which
misleads and undercuts the "we removed the private-dep friction" story. Non-breaking (cnc is a
real public gem so `gem "cnc"` still installs) but an accuracy/trust nit.

- Remove the `cnc` line from the README Installation instructions; confirm nothing else in the
  README still references `cnc` as required (grep the file).
- README-only change. `bundle exec rake` green before push. Mark done + regenerate `TASKS.md`.
- Surfaced during the `fix-broken-resource-generator-onboarding` verification pass.

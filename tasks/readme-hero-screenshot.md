---
id: readme-hero-screenshot
title: README hero screenshot of the live auto-generated admin
priority: P2
status: in_progress
domain: Marketing
created: 2026-06-26
---

Proactive trust/conversion artifact. The README (the source of truth users land on) and
the GitHub Pages landing page are text-only. A screenshot of the live demo's
auto-generated CRUD admin is the single strongest "show, don't tell" proof of the value
prop — and it makes every link in the prepared launch kit ([[discoverability-launch]])
land better.

- Capture clean screenshot(s) of the live demo (https://cafe-car-demo-production.up.railway.app)
  — the admin index with the table/filter/sort UI (e.g. `/admin/invoices` or `/admin/clients`)
  is the money shot; a show or nested-form page optional.
- Embed prominently near the top of `README.md` (hero image under the tagline) and
  `docs/index.md`.
- Image asset lives outside the built gem (gemspec globs `{app,config,db,lib}`); `rake` stays
  green. The admin is publicly reachable (no login needed).

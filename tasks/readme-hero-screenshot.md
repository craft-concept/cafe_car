---
id: readme-hero-screenshot
title: README hero screenshot of the live auto-generated admin
priority: P2
status: done
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

## Outcome

Captured the live demo with headless Chrome (puppeteer-provisioned, since no system Chrome
was installed) at a 1800px desktop viewport.

- **Hero:** `/admin/invoices` index — the full auto-generated table (sortable columns,
  currency formatting, association links, sender avatars) plus the pagination footer.
  Saved as `docs/images/admin-invoices-index.png`.
- **Secondary:** `/admin/invoices/new` — the auto-generated nested-attributes form
  (association select, typed date field, add/remove `has_many` line items).
  Saved as `docs/images/admin-invoice-form.png`.
- Images resized to 2400px wide and palette-quantized (326 KB / 58 KB).
- Embedded the hero near the top of `README.md` (absolute raw-GitHub URL, so it renders on
  both github.com and rubygems.org) and `docs/index.md` (site-relative path for Pages); the
  secondary form shot sits in the README "Forms" section.
- Gem exclusion confirmed: `gem build` produces zero `docs/` or `.png` entries (gemspec only
  globs `{app,config,db,lib}` + a few root files).

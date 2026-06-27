---
id: csv-export
title: Add CSV export to resource index actions
priority: P2
status: open
domain: Eng
created: 2026-06-27
---

Close a headline competitive gap: every comparable admin gem (ActiveAdmin, Avo,
Administrate) ships CSV export; CafeCar's index only speaks JSON/HTML/Turbo. A
"Download CSV" on every auto-generated index is a broadly-valuable adoption feature
(and the first ❌ row from [[dogfood-crayonbloom]]'s back-office readiness map).

## Scope

- Add `:csv` to the `respond_to` list in `lib/cafe_car/controller.rb:35`.
- **Export the full filtered + sorted set, not one page** — skip `paginated` when
  `request.format.csv?` (the index scope chains `…→ filtered → paginated`).
- **Columns = `policy(record).displayable_attributes`** (prefixed with `:id`), the same
  policy-respecting basis the JSON renderer uses (`controller.rb:199`). CSV must never
  leak attributes the user can't see. Header row = humanized attribute names; scalar
  attribute values only (associations out of scope for v1 — note as a follow-up).
- Add a "Download CSV" link to the index actions partial
  (`app/views/application/_index_actions.html.haml`) that points at the current index
  URL as `.csv`, **carrying the current filter + sort params** so the export matches
  what's on screen.
- Reuse the existing renderer pattern (`ActionController::Renderers` / responder) — mirror
  how JSON is handled rather than inventing a parallel path.

## Acceptance

- `index.csv` returns `text/csv` with a header row + one row per filtered record.
- Respects filters (filtered subset only) and exports **beyond a single page** (no
  pagination cap).
- Excludes non-displayable attributes (policy-respected).
- New controller tests cover the above (use the dummy app's clients/invoices).
- `CHANGELOG.md` `[Unreleased] → Added` notes the feature.
- `rake` (rubocop + test + brakeman) green; committed + pushed.

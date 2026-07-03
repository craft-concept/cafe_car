# Changelog

All notable changes to CafeCar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Dates are sourced from the project's git history. CafeCar predates this changelog,
so the `0.1.1` entry was reconstructed from commit logs and may not be exhaustive.

## [Unreleased]

### Added

- Dashboard overview. A new opt-in surface that composes an app's data into a
  single overview page. A host declares it once with a `CafeCar.dashboard { ... }`
  block of **metric tiles** (`metric "Users", -> { User.count }` — a label over a
  number from a host-supplied callable) and **charts** (`chart "New users", model:
  User, x: :created_at, by: :month` — the same inline-SVG bar chart the index Chart
  view uses). Widgets render in a responsive grid at `dashboard_path` (no
  JavaScript, CSP-safe). The route is mounted **only** when a dashboard is
  declared, so a CRUD-only host never inherits a blank page. Chart widgets keep the
  Chart-view security discipline: the x column is validated against the model's
  date-column allowlist and truncated via portable Arel, so a column name can never
  reach SQL raw.
- Chart view on index pages. Alongside grid and table, every index now offers a
  **Chart** view that aggregates records into time buckets and plots them as a
  count-per-bucket bar chart. Pick any date/datetime column as the x-axis and a
  day/week/month granularity from a small GET form that composes with the active
  filters and sort. The chart aggregates over the **same policy-scoped, filtered
  relation** the table renders, so filters narrow it and rows the user can't see
  are never counted. Aggregation is a database `GROUP BY` on a portable Arel date
  truncation (`strftime` on SQLite, `date_trunc` on Postgres) — no raw SQL — and
  the x-axis column is validated against an allowlist of the model's displayable
  date columns, so a param can never be interpolated as a column name. Rendered as
  dependency-free inline SVG (no JavaScript, CSP-safe). Models with no date column
  show a friendly message instead.
- Searchable association selects. A `belongs_to`/`has_many` field (`f.association`)
  is now enhanced with [Tom Select](https://tom-select.js.org) (vendored — no CDN,
  no bundler, no runtime dependency) for keystroke typeahead. The initial option
  list is still capped at `CafeCar.max_collection_options`, but the typeahead now
  queries a per-model JSON `options` endpoint (`GET /<resources>/options?q=`), so a
  record **past the cap** is reachable — closing the gap where a large association
  was usable-but-truncated. The endpoint is authorized through `index?` plus the
  policy scope, so search never returns rows the user can't see, and results are
  capped at the same page size. Enhancement is progressive: with JavaScript
  disabled or failing, the field stays a working plain select, and the currently
  associated record is always kept among the options even when it sorts past the
  cap (so editing never silently drops the value).
- Bulk actions on index tables. Every index now carries a per-row checkbox and a
  "select all" header checkbox; selected rows are submitted to a `batch`
  collection endpoint that applies a named action to them. **Delete** ships built
  in. Authorization is per-record: the candidate set is narrowed to the policy
  scope, then each row is checked against the action's policy predicate
  (`destroy?` for delete) — unauthorized rows are skipped, never bulk-bypassed.
  Hosts register custom actions with `CafeCar.bulk_action(:publish) { … }`
  (optional `query:` names the policy predicate; the block defaults to
  `record.public_send(:"#{name}!")`). Candidates load and authorize in a single
  query regardless of batch size.

### Fixed

- The documented URL filter syntax now works. Filtering is a headline feature,
  but bare filter keys were silently dropped: `?price.min=10` or `?name=Widget`
  returned the full, unfiltered result set with no error, so a developer who
  copy-pasted a README example saw nothing happen. Two gaps caused it — only
  literal leading-dot keys (`.name`) reached the query DSL, and the `.min` /
  `.max` / `.gt` / `.lt` / `.eq` word-form operators were never interpreted.
  Now every non-control request param is treated as a filter (routed through
  the query DSL), and the word-form operators map to their comparisons
  (`min`/`max` alias `gte`/`lte`). Range (`created_at=2024-01-01..2024-12-31`)
  and array/IN (`tags=a,b,c`) filters compose with them. The former
  leading-dot form is removed in favor of the documented bare-key syntax.
- Index pages now eager-load the associations they render, so a table is a
  bounded number of queries instead of one-per-row-per-association (N+1). The
  scope pipeline `includes` each displayed `belongs_to`/`has_many` column and
  nests the association's preview attachment (e.g. an `owner`'s avatar) so it
  isn't a second-order N+1 either. Polymorphic associations are skipped (they
  can't be naively `includes`d). Previously a 15-row table issued ~37 queries
  and grew linearly with row count.
- Nested `accepts_nested_attributes_for` forms now persist. The form-inference layer
  resolved a nested-attributes permit only under the bare association name
  (`line_items`), but Rails' `fields_for` and strong-params name the key
  `line_items_attributes`. `CafeCar::FieldInfo#reflection` now resolves the
  `<assoc>_attributes` key back to its association (mirroring `nested_attributes_type`),
  so a policy that permits `line_items_attributes: [...]` both renders the repeatable
  fields and saves the child records. Previously such a form returned HTTP 200 while
  silently dropping every nested row; with `:id` + `:_destroy` permitted, existing
  children now update and delete via `_destroy` too.
- `cafe_car:resource` now permits a `:references`/`belongs_to` field by its foreign key.
  `rails g cafe_car:resource Order client:references` generated a policy permitting the
  bare `:client`, but the column strong-params receives is `:client_id`, so the
  association silently could not be saved. References are translated to `<name>_id`
  (and `<name>_type` for `references{polymorphic}`) before forwarding to `cafe_car:policy`.

## [0.2.1] - 2026-07-01

### Fixed

- The advertised primary onboarding flow (`rails g cafe_car:resource Product name:string
  price:decimal`) no longer 500s out of the box in a fresh, CRUD-only app. Three bugs
  compounded to break it:
  - `current_user` (Pundit's default `pundit_user`, evaluated on every authorized
    request) unconditionally built a `CafeCar::Session`, which requires the opt-in
    `sessions` table and a `User` model. A host that never ran `cafe_car:sessions` got
    a 500 on every action instead of degrading to 403 Forbidden. `current_session` now
    consults the existing `sessions_available?` gate and returns `nil` when the
    infrastructure is absent, so plain CRUD works with no login.
  - `cafe_car:resource` dropped the field list when delegating to `cafe_car:policy`,
    forcing the fragile model-introspection path. It now forwards the field names.
  - `cafe_car:policy` called `CafeCar::ModelInfo.new(model_class)` positionally, but the
    initializer requires the `model:` keyword — an `ArgumentError` whenever the model
    resolved. It now passes the keyword, and the generated policy lists the forwarded
    fields even when the model isn't a loaded constant mid-run (instead of writing a
    `:create_model_first_to_generate_attributes` placeholder).

## [0.2.0] - 2026-06-30

### Removed

- Dropped `faker` as a runtime dependency. It was a hard runtime requirement solely
  because the shipped, routed `/components` UI styleguide used `Faker::Lorem` for the
  Alert demo copy. That partial now uses static sample lorem text, so host apps no
  longer get faker forced into their production bundle. (faker remains a dev/test
  dependency, and the installer still adds it to host Gemfiles for factories/seeds.)
- Dropped the unused `web-console` runtime dependency from the gemspec. It was a
  development/debugging gem never referenced by CafeCar's own code, and shipping it
  as a runtime dependency forced an interactive console into host applications'
  production bundles — a footgun with no upside. Smaller install footprint.

### Added

- Turnkey keyword search on every auto-generated index: a search box filters the
  table by matching a term across the model's string/text columns, case-insensitively
  and DB-portably (Arel `#matches` emits `ILIKE` on Postgres, `LIKE` on SQLite/MySQL).
  Works out of the box with no per-model setup; columns the parameter filter hides
  (passwords, tokens, ...) are never searched, mirroring the policy's displayable
  guarantee. A host-defined `scope :search` still takes precedence. The box round-trips
  the term, preserves the active dot-filters + sort, and is cleared by "View all".
- CSV export on every auto-generated index: a "Download CSV" action exports the
  filtered + sorted result set as `text/csv`. Columns reuse the JSON renderer's
  policy-respecting basis (`[:id] | displayable_attributes`), narrowed to scalar
  columns, so exports never leak attributes the policy hides. The link carries the
  current filter/sort params so the export matches what's on screen. Output is
  bounded at `CafeCar.csv_export_row_limit` rows (default 10,000) to cap memory on
  large tables; a truncated export sets an `X-CafeCar-Truncated: true` response
  header and logs a warning. Associations are out of scope for v1.
- Nested-attributes form rendering for `has_many` associations configured with
  `accepts_nested_attributes_for`. CafeCar now renders repeatable nested fields
  with add/remove buttons (vanilla JS, no Stimulus): "Add" clones an HTML
  `<template>` for a new record, and "Remove" drops unsaved rows or marks
  persisted rows for destruction via their `_destroy` field (when
  `allow_destroy` is set). Association detection still falls back to the prior
  behavior unless `accepts_nested_attributes_for` is actually configured.

### Fixed

- Pundit's `verify_authorized`/`verify_policy_scoped` are now scoped to the
  `cafe_car` macro instead of firing for every controller that merely includes
  `CafeCar::Controller`. Wiring the concern into `ApplicationController` (the
  obvious adoption path) no longer makes plain controllers — Rails-generated
  passwords/sessions, custom pages, health checks — 500 on
  `Pundit::PolicyScopingNotPerformedError`; verification now ships with the
  auto-CRUD it guards. `cafe_car` resource controllers still authorize + verify.
- Keyword search: a crafted non-string `q` param (e.g. `?q[x]=y` or `?q[]=a`) is
  now ignored instead of raising an unhandled 500.
- CSV export: text values that look like spreadsheet formulas (leading `=`, `+`,
  `-`, `@`) are prefixed with a quote, neutralizing CSV formula injection when an
  exported file is opened in Excel/Sheets.
- Generators now honor the intended destination. `rails g cafe_car:resource`
  (and the policy/controller generators it delegates to) write through a shared
  inline `generate` helper that passes `destination_root` explicitly, instead of
  leaking files into the engine repo or escaping the target directory.
- The policy generator applies namespacing correctly: it emits a single
  `module Admin` wrapper via `module_namespacing` and resolves namespaced model
  lookups by file path, matching the controller generator's behavior.

## [0.1.2] - 2026-06-26

### Added

- Optional sessions/authentication: an opt-in email/password login feature with
  engine routes, a generator, login/logout, and documentation. It is off by
  default and only activates when an app opts in.
- The `cafe_car` controller macro now accepts a `model:` keyword for explicit
  model selection.
- "New" action now carries the current filters through, and pagination info
  reports when a filtered subset is shown.
- Code presenter (syntax-highlighted source via Rouge) and richer presenters.
- UI polish: tooltips, navigation icons, the Lexend font, and a popup component.

### Changed

- Renamed the controller macro from `recline_in_the_cafe_car` to `cafe_car`.
- Switched RuboCop to the `rubocop-rails-omakase` shared config.
- Made the gemspec release-grade: a distinct summary/description, a Ruby `>= 3.3`
  floor, `bug_tracker_uri` and `rubygems_mfa_required` metadata, and conservative
  version floors on the runtime dependencies. Homepage now points at the GitHub
  Pages site.
- Bumped vulnerable transitive dependencies to clear all open Dependabot alerts.
- Added configurable views and improved handling of namespaced resources.
- CI: decoupled the Brakeman gate from the gem version and refreshed the Brakeman
  ignore file so CI is green independently of releases; the RuboCop gate now runs
  check-only.
- Removed network calls from the test suite for deterministic, offline test runs.
- Bumped Brakeman.
- UI fixes, including removing the table blur.

### Fixed

- Sessions denial now returns `403` instead of a `500`.
- `500` errors when showing an unpersisted session and when scoping records for a
  signed-out user.
- Singular-resource URLs so the session login form renders correctly.
- Sessions auth flow end to end, including login form rendering.
- `turbo_stream` links not rendering HTML by default; disabled turbo-stream on the
  index action.
- Invalid ranges in `ParamParser`.
- Viewing a record version after the item was destroyed.
- Allowed admins to update and destroy users.
- Date presentation, breadcrumbs, navigation `ui_class`, image flicker, and form
  error messages.

### Removed

- The `cnc` runtime dependency. The two core-extension methods CafeCar relied on
  (`Hash#extract_if!` and `Module#define_class`) are now inlined under
  `lib/cafe_car/core_ext/`.

## [0.1.1] - 2026-02-26

Initial documented release of the CafeCar Rails engine: a "view"-layer extension
that auto-generates CRUD UI (index, show, new, edit) with sensible, overridable
defaults for admin panels, internal tools, and rapid prototyping.

### Added

- Auto-generated CRUD interfaces via the controller macro, with RESTful actions
  and JSON/HTML/Turbo Stream responders.
- Pundit-based authorization with attribute-level permissions and auto-detected
  displayable attributes and associations.
- Type-aware presenters (records, dates, currency, ranges, Active Storage
  attachments, Action Text, enumerables, and nil handling).
- Composable UI component system (Page, Grid, Row, Card, Table, Field, Button,
  Modal, Alert, Menu, Navigation) with grid view and camel-case component methods.
- Enhanced form builder with smart field detection, nested attributes, and
  association selects.
- Advanced URL-based filtering (ranges, comparisons, arrays) and multi-column
  sorting.
- Generators for resources, controllers, policies, and polymorphic audit notes.
- Support for models with composite primary keys.
- Comprehensive README documentation.

### Changed

- Adopted the `responders` gem for response handling.

[Unreleased]: https://github.com/craft-concept/cafe_car/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/craft-concept/cafe_car/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/craft-concept/cafe_car/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/craft-concept/cafe_car/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/craft-concept/cafe_car/releases/tag/v0.1.1
</content>
</invoke>

# Changelog

All notable changes to CafeCar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Dates are sourced from the project's git history. CafeCar predates this changelog,
so the `0.1.1` entry was reconstructed from commit logs and may not be exhaustive.

## [Unreleased]

### Added

- Browser-level coverage for nested form rows, bulk selection, and remote
  searchable association selects.
- CI coverage for Rails 8.0/8.1 on Ruby 3.3/4.0, exact dependency floors, the
  JavaScript advisory audit, and build/install/boot of the packaged gem.
- `listable_attributes` and `displayable_attributes` policy hooks for narrowing
  the default read surfaces, including custom sensitive columns.

### Changed

- Sessions now use browser cookies with 30-day absolute and two-hour idle
  server-side lifetimes. Successful authentication rotates both the CafeCar and
  Rails sessions; stale or expired cookies are cleared safely.
- The core installer no longer changes the host Gemfile. The optional sessions
  generator adds its own bcrypt dependency.
- Runtime dependencies now carry tested lower bounds and intentional upper
  bounds; Rails 8.0 and 8.1 have committed compatibility locks.

### Fixed

- Mounting the engine no longer strips Rails' `field_with_errors` wrapper from a
  host app's own forms; the wrapper is dropped only inside CafeCar's own forms.
- The `present` formatting helper is now available on its own via
  `CafeCar::Formatting`, so a host can format values app-wide without the
  admin-only `link_to`/`capture`/`method_missing`/`p` overrides in
  `CafeCar::Helpers`.
- A policy-permitted member/collection action with no controller override and no
  matching model method now fails closed with a clean authorization error instead
  of a raw `NoMethodError`; the model-bang convention logs a warning when it fires.
- Malformed filter and pagination input can no longer invoke JSON parsing,
  constant lookup, user-authored regular expressions, or invalid page sizes.
- CSV exports now mark truncation only when at least one row was omitted.
- Rails 8.0 chart grouping no longer emits an aliased expression in `GROUP BY`.
- Shipped interface copy now comes from locales and has a regression guard.
- Removed an unused engine migration and moved dummy-app password-reset views
  out of the runtime package.
- Corrected stale public API guidance for custom actions, responder overrides,
  view override paths, generator output, supported versions, and the canonical
  live-demo URL.

## [0.3.1] - 2026-07-13

### Security

- Restricted the development debug surface to local development requests and
  removed session/cookie internals from its output.
- Singular JSON responses now serialize policy-displayable scalar attributes
  only; associations are no longer included without their own authorization and
  serialization contract.
- Association selects, filter labels, and submitted association ids now require
  the associated model's `index?` permission and Pundit scope. Foreign keys
  outside that boundary—including polymorphic and nested association ids—are
  denied server-side rather than relying on the select control as the boundary.
- The opt-in dashboard now requires `DashboardPolicy#show?`, and its built-in
  metric/chart helpers aggregate over each model's policy scope.

### Changed

- Index views resolve through the shipped `table`, `grid`, and `chart` allowlist;
  an unknown `view` parameter falls back safely instead of selecting a partial.
- The release workflow now runs the full check suite and verifies that a tagged
  commit belongs to `main` before publishing it to RubyGems.

## [0.3.0] - 2026-07-10

### Added

- Policy-declared custom actions. A policy can now declare **member** and
  **collection** actions through `permitted_member_actions` and
  `permitted_collection_actions`, and CafeCar wires each one up with no
  registration: the action name (`publish`) forwards to the model bang method
  (`publish!`), authorized by the matching policy predicate (`publish?`). Actions
  render as policy-gated buttons on the show page and on each index/grid card, and
  the response is a Turbo morph refresh so the page updates in place. A collection
  action runs over the **currently-viewed (filtered) scope**, not the whole policy
  scope, so it acts on exactly what's on screen; its button carries a localized
  count hint (e.g. `Publish all 21`, `en.cafe_car.actions.all`). Every label and
  style comes from the locale.
- Typed, policy-driven filter panel on every index. The index aside now renders a
  filter control per attribute in the model policy's **`permitted_filters`** (the
  same source of truth the URL-filter gate enforces), each typed by reflection:
  strings/text get a *contains* input (the `~` dot-op), enums a select of their
  declared values, booleans an any/true/false select, numerics and dates a min/max
  range pair (`price.min`/`price.max`; dates parse through Chronic), `belongs_to` the
  Tom Select typeahead the edit form already uses (`?author_id=…`), and `has_many` a
  "has this record" typeahead (`?line_items.id=…`). Each `permitted_scopes` entry gets
  a checkbox toggle (`?published=true`). The form submits via GET, composes with the
  active search, sort, and view (round-tripped as hidden fields), and active values
  round-trip back into the controls. Every per-type control is a host-overridable
  partial (`_string_filter`, `_enum_filter`, `_range_filter`, …) — views, not a config
  DSL — and all copy lives in locales.
- Nested-association (dot-path) filters. A policy may declare a filter that reaches
  across an association as a dot-path in **`permitted_filters`** (e.g. `client.status`,
  `client.owner`); the panel renders a typed control for it — the terminal attribute on
  the far model picks the type (nested enum → enum select, nested `belongs_to` →
  association multi-select) — and the query DSL composes the join. The allowlist gate now
  validates the **full** nested path: filter params are descended recursively into the far
  model and a leaf is kept only when its whole dot-path is permitted, so a crafted
  `?client.owner.secret=` — an undeclared path even when it names a real far column — is
  dropped before any join is built, exactly like an unpermitted top-level column. (A
  permitted association's `.id` set-membership control, `?line_items.id[]=`, stays the one
  implicit allowance, as before.) Copy lives in locales.
- Active-filter chips on the index. The applied (policy-gated) filters now render above the
  results as removable chips with a **Clear all** — removing a chip drops only that one
  filter key and clear-all drops them all, both preserving the rest of the query (search
  `q`, sort, view, and the other filters) so chips compose with the search box and the
  CSV/chart export links. Chip labels come from the same policy/locale-driven source the
  panel controls read (a nested `client.status` chip labels off its terminal attribute), and
  an association filter resolves to the referenced record's **title** — the same presenter
  title the filter's typeahead lists — so a chip reads `Client: Acme Corp`, not the raw id
  (`Client: 42`), falling back to the id only for a stale/unresolvable one. Rendered through
  a host-overridable `_active_filters` partial; styling is component-scoped and all copy
  lives in locales.
- Selectable chart y-metric. The index Chart view can now plot the **sum or average
  of a numeric column** on the y-axis, not just a record count. A `chart_y` select
  offers `count` (the default — nothing regresses) plus a sum and average per
  chartable numeric column. The chartable columns come from the **policy** (the
  model's displayable numeric attributes — the same source of truth as the x-axis
  date columns), so the policy stays authoritative and a `chart_y` param is validated
  against that allowlist before it reaches the query — a raw column name can never be
  interpolated. Aggregation uses adapter-neutral ActiveRecord calculations
  (`COUNT`/`SUM`/`AVG`), portable across SQLite and Postgres. Labels come from locales.
- Dashboard overview. A new opt-in surface that composes an app's data into a
  single overview page — configured, like everything in CafeCar, **through a view,
  not a config DSL.** A host turns it on by writing one template,
  `app/views/cafe_car/dashboard/show.html.haml`, that composes three helpers:
  **`metric("Label") { … }`** (a label over a number), **`metrics(Model)`** (the
  count tiles a model policy declares in `permitted_metrics` — the policy is the
  source of truth, same as bulk actions), and **`chart "Title", model:, x:, by:`**
  (the same inline-SVG bar chart the index Chart view uses). The template's
  existence is the opt-in: no template → a direct hit 404s and no nav link shows,
  so a CRUD-only host never inherits a blank page. Tiles render in a responsive grid
  at `dashboard_path` (no JavaScript, CSP-safe). Charts keep the Chart-view security
  discipline: the x column is validated against the model's date-column allowlist
  and truncated via portable Arel, so a column name can never reach SQL raw.
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
  in. The **policy is the source of truth**: a policy declares the actions its
  index offers with `permitted_bulk_actions` (default `%i[destroy]`), and the
  action bar renders exactly that list — override the `_bulk_actions` partial to
  opt out. A custom action "just works" from three conventional pieces with no
  registration anywhere: its name in `permitted_bulk_actions`, a model bang method
  (`publish!`) for behavior, and a policy predicate (`publish?`) for authorization.
  `batch` derives both from the name and rejects any name outside the policy list.
  Authorization is per-record: the candidate set is narrowed to the policy scope,
  then each row is checked against `name?` — unauthorized rows are skipped, never
  bulk-bypassed. Button labels and styles come from the locale (`en.destroy`;
  `bulk_actions.styles.destroy: danger`). Candidates load and authorize in a single
  query regardless of batch size.

### Changed

- Form inputs now render through Ruby component objects (`CafeCar::Inputs::*`,
  wired into `FormBuilder#input`) — each field type resolves to its own component
  rather than an inline builder branch. Rendered output and form behavior are
  unchanged; the payoff is a per-type override seam and a single place to extend
  input rendering.

### Fixed

- `?sort=` keys are now gated to the policy's `permitted_filters`, the same
  allowlist the URL-filter gate enforces. A sort key outside that list is ignored
  instead of ordering by an arbitrary column, closing the parity gap where filtering
  was gated but sorting was not.
- `default_view` now inherits to controller subclasses. It was stored in a class
  instance variable that silently reset to the default in any subclass, so a base
  controller setting a non-default view didn't carry down; it now resolves through
  inheritance.
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

- Turnkey keyword search on every rendered index: a search box filters the
  table by matching a term across the model's string/text columns, case-insensitively
  and DB-portably (Arel `#matches` emits `ILIKE` on Postgres, `LIKE` on SQLite/MySQL).
  Works out of the box with no per-model setup; columns the parameter filter hides
  (passwords, tokens, ...) are never searched, mirroring the policy's displayable
  guarantee. A host-defined `scope :search` still takes precedence. The box round-trips
  the term, preserves the active dot-filters + sort, and is cleared by "View all".
- CSV export on every rendered index: a "Download CSV" action exports the
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
that renders CRUD UI (index, show, new, edit) with sensible, overridable
defaults for admin panels, internal tools, and rapid prototyping.

### Added

- CRUD interfaces rendered through the controller macro, with RESTful actions
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

[Unreleased]: https://github.com/craft-concept/cafe_car/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/craft-concept/cafe_car/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/craft-concept/cafe_car/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/craft-concept/cafe_car/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/craft-concept/cafe_car/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/craft-concept/cafe_car/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/craft-concept/cafe_car/releases/tag/v0.1.1

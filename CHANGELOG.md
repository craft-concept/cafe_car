# Changelog

All notable changes to CafeCar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Dates are sourced from the project's git history. CafeCar predates this changelog,
so the `0.1.1` entry was reconstructed from commit logs and may not be exhaustive.

## [Unreleased]

### Added

- Nested-attributes form rendering for `has_many` associations configured with
  `accepts_nested_attributes_for`. CafeCar now renders repeatable nested fields
  with add/remove buttons (vanilla JS, no Stimulus): "Add" clones an HTML
  `<template>` for a new record, and "Remove" drops unsaved rows or marks
  persisted rows for destruction via their `_destroy` field (when
  `allow_destroy` is set). Association detection still falls back to the prior
  behavior unless `accepts_nested_attributes_for` is actually configured.

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

[Unreleased]: https://github.com/craft-concept/cafe_car/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/craft-concept/cafe_car/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/craft-concept/cafe_car/releases/tag/v0.1.1
</content>
</invoke>

# Changelog

All notable changes to CafeCar are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Dates are sourced from the project's git history. CafeCar predates this changelog,
so entries for `0.1.1` and `0.1.2` were reconstructed from commit logs and may not be
exhaustive.

## [Unreleased]

### Fixed

- Sessions auth flow: corrected the login form rendering and the end-to-end
  authentication path so the test suite is green.
- 500 errors when showing an unpersisted session and when scoping records for a
  signed-out user.
- Singular-resource URLs so the session login form renders correctly.
- RuboCop offenses in `param_parser_test`.

### Changed

- CI: decoupled the Brakeman gate from the gem version and refreshed the Brakeman
  ignore file so CI is green independent of releases.
- Removed network calls from the test suite for deterministic, offline test runs.
- Onboarded the project into the holdco operating model with a one-file-per-task
  backlog under `tasks/` (see `AGENTS.md` and `TASKS.md`).

## [0.1.2] - 2026-02-28

### Changed

- Renamed the controller macro from `recline_in_the_cafe_car` to `cafe_car`.
- Added configurable views and improved handling of namespaced resources.
- UI fixes, including removing the table blur.
- Bumped Brakeman.

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

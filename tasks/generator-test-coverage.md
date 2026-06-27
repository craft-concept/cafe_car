---
id: generator-test-coverage
title: Add test coverage for the generators
priority: P1
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

The feature audit (`V1_SCOPE.md`) flagged the generators as a major coverage gap:
`install` / `resource` / `controller` / `notes` are uncovered (install/notes test files
are empty stubs). The **`install` generator is the riskiest untested path** — it mutates
the host's Gemfile, routes, and ApplicationController. Generators are the first thing a new
adopter runs; if they break, trust is gone on contact.

- Add `Rails::Generators::TestCase` coverage for each generator under `test/generators/`.
- `install`: assert it injects the expected deps, mounts the engine, creates the policy,
  adds `CafeCar::Controller`, and wires JS imports — without duplicating on re-run.
- `resource` / `controller` / `policy`: assert the generated files + content.
- `notes`: assert migration + model + concern.
- `sessions`: a test likely already exists from the recent sessions work — extend if thin.
- Fill in the empty stub test files. `rake` green.

Supersedes item 4 of [[fix-halfbaked-features]].

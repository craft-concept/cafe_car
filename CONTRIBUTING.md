# Contributing to CafeCar

Thanks for your interest in CafeCar! It's a Rails engine that auto-generates CRUD
UI with sensible, overridable defaults. Contributions of all kinds are welcome —
bug reports, fixes, features, and docs.

## Development setup

CafeCar is a gem with a dummy Rails app under `test/dummy/` for development and
testing.

```bash
git clone https://github.com/craft-concept/cafe_car.git
cd cafe_car
bundle install
```

> Note: CafeCar currently depends on the private `cnc` gem. Resolving that
> dependency for outside contributors is tracked in the backlog (see below).

### Running the dummy app

The engine is mounted in a host app at `test/dummy/`. Run it like any Rails app:

```bash
bin/rails db:prepare
bin/rails server
```

This boots the dummy app with CafeCar mounted so you can click through the
generated UI while you work.

### Running tests

The suite is minitest. Run all tests with:

```bash
bin/rails test
```

Run a single file or test with the usual minitest arguments:

```bash
bin/rails test test/controllers/some_controller_test.rb
bin/rails test test/controllers/some_controller_test.rb:42
```

### The full check suite

Before opening a PR, run the same suite CI runs:

```bash
bundle exec rake
```

`rake` runs **RuboCop**, the **test** suite, and **Brakeman** (static security
analysis). All three must be green. "Green on my files" is not the same as a green
`rake` — always run the full suite.

## The backlog

CafeCar's backlog lives on the holdco-tasks board (the one task system fleet-wide).
The operator files, lists, and closes tasks with `bin/operate tasks` (`bin/operate tasks
--help` shows the full surface). See `AGENTS.md` for the conventions.

If you're picking up work, open an issue to discuss new work first.

## Pull requests

A good PR:

- **Adds tests** for new behavior or a regression test for a fix.
- **Keeps `rake` green** — RuboCop, tests, and Brakeman all pass.
- **Updates `CHANGELOG.md`** — add a bullet under `[Unreleased]` describing your
  change ([Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format).
- **Stays focused** — one logical change per PR; don't bundle unrelated work.

By contributing, you agree your contributions are licensed under the project's
[MIT License](MIT-LICENSE).

## Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating you
are expected to uphold it.

## Security

Please do not file public issues for security vulnerabilities. See
[SECURITY.md](SECURITY.md) for private disclosure instructions.
</content>
</invoke>

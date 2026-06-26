# CafeCar v1 Scope

> **Update 2026-06-26:** since this audit, **sessions/auth has been made optional AND
> finished** (engine routes, configurable `user_class_name`, honest generator, README docs,
> tests; CRUD-only hosts now 403 instead of 500). The "OUT / EXPERIMENTAL" verdict on
> sessions below is superseded — it's now opt-in and supported. Also: `cnc` was cut
> wholesale and rubocop moved to rails-omakase. The rest of the audit stands.

> Evidence-based feature audit. Current version: `0.1.2` (`lib/cafe_car/version.rb`).
> Tree state at audit: `bundle exec rake` is **green** — RuboCop clean (187 files),
> 51 runs / 80 assertions / 0 failures, Brakeman 0 warnings.
>
> Status legend:
> - **IN** — works, documented honestly, has at least indirect test coverage. Commit to it at 1.0.
> - **NEEDS-WORK** — works but under-tested, partially coupled, or its docs drift from reality. Must close gaps before 1.0.
> - **OUT / EXPERIMENTAL** — incomplete, undocumented, or actively churning. Do not market as 1.0; gate behind an "experimental" label or cut.

## TL;DR

- **Auth/sessions verdict: EXPERIMENTAL (do not ship as a 1.0 feature).** The login flow
  works *in the dummy app* only because the dummy hand-wires routes and a `User` model.
  The engine ships no session routes, no `User`, and an incomplete generator whose USAGE
  lies. It is also force-coupled into every CRUD controller. See the dedicated section.
- **Counts: 8 IN · 7 NEEDS-WORK · 2 OUT/EXPERIMENTAL** (18 audited features).
- **README false advertising found** — see "README accuracy" below (3 concrete copy-paste-fails
  plus an entire undocumented auth subsystem).

---

## Feature inventory

| # | Feature | Status | Evidence | Notes |
|---|---------|--------|----------|-------|
| 1 | Auto-CRUD controller (`cafe_car`) | **IN** | `lib/cafe_car/controller.rb:19-44,84-102`; tests `test/all_controllers_test.rb` (7 actions × articles/clients/invoices/notes), `test/controllers/admin/clients_controller_test.rb` | Core of the gem. All 7 RESTful actions, `only:`/`except:`, custom `model`, lifecycle callbacks all exercised. Strongest feature. |
| 2 | Authorization (Pundit) | **IN** | `lib/cafe_car/policy.rb`, `app/policies/cafe_car/application_policy.rb`; `after_action :verify_authorized, :verify_policy_scoped` (`controller.rb:81`) enforced on every controller test | `permitted_attributes`, `displayable_attributes`, Scope pattern all live. Validated indirectly by every passing controller test. |
| 3 | Filtering (query DSL) | **IN** | `lib/cafe_car/query_builder.rb`, `lib/cafe_car/param_parser.rb`, `lib/cafe_car/controller/filtering.rb`; tests `test/cafe_car/queryable_test.rb` (attributes, associations, scopes, counts), `test/cafe_car/param_parser_test.rb` (ranges) | Best-tested non-controller subsystem. Operators (`!`, ranges, association counts, regex) covered. |
| 4 | Presenters | **NEEDS-WORK** | `app/presenters/cafe_car/*` — all 10 README-documented presenters exist (record/date/date_time/currency/range/attachment/rich_text/enumerable/hash/nil_class); only test is `test/presenters/cafe_car/presenter_test.rb` with **a single assertion** (`Presenter.find(Symbol)`) | Works (exercised when show/index views render), but direct coverage is ~nil. Formatting/`to_html`/`attributes`/`associations` untested. |
| 5 | UI component system | **NEEDS-WORK** | `app/ui/cafe_car/ui/{button,card,field,grid,layout,page}.rb` (6 Ruby classes); README advertises 11 (adds Row, Table, Modal, Alert, Menu, Navigation). Generic fallback in `lib/cafe_car/context.rb:12-15`; CSS + example partials exist for all under `app/assets/stylesheets/ui/` and `app/views/cafe_car/examples/ui/` | The 5 "missing" components render via the generic `Component` + partial fallback, so they don't 500 — but the surface is uneven and the only test (`test/cafe_car/component_test.rb`) tests `capture`/`concat` plumbing, not any component. |
| 6 | Forms / form builder | **NEEDS-WORK** | `lib/cafe_car/form_builder.rb` (`input`, `association`, `field`, `submit`), `lib/cafe_car/field_builder.rb`; exercised by new/edit/create in `all_controllers_test` | Works. **Doc drift:** README shows `f.field(:price).errors` but the method is `error` (singular) — `field_builder.rb:20`. No `errors` method exists. Smart-type detection has no dedicated unit test. |
| 7 | Pagination & sorting | **NEEDS-WORK** | Kaminari wired in `controller.rb:124` (`paginated`); sorting in `lib/cafe_car/model.rb:8-21` (`sorted`/`normalize_sort_key`) | No direct sort/paginate test (only indirect via index actions). **Doc drift:** README says the model gets `normalized_sort_key()`; the actual method is `normalize_sort_key` and is an internal helper, not public API. |
| 8 | Hotwire / Turbo Streams | **NEEDS-WORK** | `respond_to :turbo_stream` (`controller.rb:35`); views `app/views/cafe_car/application/{create,update,destroy,edit,new}.turbo_stream.haml`; `lib/cafe_car/turbo_tag_builder.rb` | Advertised "out of the box" but **no test requests `format: :turbo_stream`** — every controller test hits HTML/redirect. Templates exist and look coherent; correctness is unverified. |
| 9 | Current context | **IN** | `lib/cafe_car/current.rb` — `request_id`, `user_agent`, `ip_address`, `session`, delegated `user`; set in `controller.rb:210-214` | All README-documented attributes present and wired via `set_current_attributes`. Lightly (indirectly) tested. |
| 10 | Generator: install | **NEEDS-WORK** | `lib/generators/cafe_car/install/install_generator.rb`; test `test/lib/generators/cafe_car/install_generator_test.rb` is **commented out (empty)** | Adds gems beyond the README list (`cnc` from a GitHub repo, `hotwire-livereload`, `better_errors`, `binding_of_caller`, `chrome_devtools_rails`, `i18n-debug`). Mutates Gemfile + runs `bundle install` — highest-risk generator and it has **zero coverage**. |
| 11 | Generator: resource | **IN** | `lib/generators/cafe_car/resource/resource_generator.rb`; verified via `rails g cafe_car:resource Payment ... --pretend` → creates migration, model, controller, policy, route | Works. No automated test (coverage gap), but functionally sound. |
| 12 | Generator: controller | **IN** | `lib/generators/cafe_car/controller/controller_generator.rb`; verified live — emits a correct namespaced `cafe_car` controller | Works. No dedicated test. |
| 13 | Generator: policy | **IN** | `lib/generators/cafe_car/policy/policy_generator.rb`; test `test/lib/generators/cafe_car/policy_generator_test.rb` **passes**; verified live (derives `permitted_attributes` from model columns) | Best-covered generator. Solid. |
| 14 | Generator: notes | **IN** | `lib/generators/cafe_car/notes/notes_generator.rb`; verified via `--pretend` (migration + Note model + Notable concern + policy + controller); test file is **commented out (empty)** | Works end-to-end. Coverage gap only. |
| 15 | Generator: sessions | **OUT / EXPERIMENTAL** | `lib/generators/cafe_car/sessions/sessions_generator.rb` | **Undocumented in README.** Only creates the migration — the model template is commented out (`sessions_generator.rb:8`), yet its USAGE claims it creates `app/models/session.rb` **and** `app/policies/session_policy.rb`. It creates **neither**. False USAGE. |
| 16 | Auth / Sessions subsystem | **EXPERIMENTAL** | See dedicated section below | Heavy recent churn; works only in the hand-wired dummy. Not v1-ready. |
| 17 | JSON responses | **NEEDS-WORK** | `controller.rb:197-208` (`_render_with_renderer_json` restricts to displayable attrs); `respond_to :json` | Advertised ("JSON/HTML/Turbo Stream responses"). No JSON-format test. |
| 18 | View overriding / customization | **IN** | Default views in `app/views/cafe_car/application/`; host override demonstrated in `test/dummy/app/views/articles/*` and asserted by the articles index/show tests | Documented mechanism works (dummy overrides articles views and tests pass). |

---

## Auth / Sessions — detailed verdict: **EXPERIMENTAL, not v1-ready**

The login flow *does* function: `test/controllers/sessions_controller_test.rb` (4 tests — form
renders, unpersisted show, failed login re-renders with error, successful login sets cookie)
all pass, and `test/test_helper.rb`'s `sign_in` helper drives the real POST `/session` flow. So
the mechanism is coherent enough to log a user in.

But it is **not a shippable engine feature** for these concrete reasons:

1. **The engine exposes no session routes.** `config/routes.rb` (the engine's routes) only maps
   `get 'components'`. Mounting `CafeCar::Engine` gives a host app **no login page**. Auth works
   in tests solely because `test/dummy/config/routes.rb:2` hand-declares
   `resource :session, controller: "cafe_car/sessions"`. Nothing generates or documents this.

2. **Hard dependency on a host `User` the engine never provides.** `app/models/cafe_car/session.rb:14`
   hardcodes `User.authenticate_by(...)` and `belongs_to :user`, assuming a host `User` with
   `has_secure_password`, an `email`, and `authenticate_by`. There is no `User` generator and no
   docs telling the host what to build. The dummy's `User` (`test/dummy/app/models/user.rb`) is the
   only thing that makes it work.

3. **Auth is force-coupled into every CRUD controller.** `lib/cafe_car/controller.rb:8` does
   `include Filtering, Authentication`. So `current_user`/`current_session` and the
   `render_unauthorized → request_authentication` path (`controller.rb:174-180`) are wired into
   *every* `cafe_car` controller. `current_session` (`authentication.rb:19-26`) builds a
   `CafeCar::Session.new`, which assumes the sessions table exists. A host that adopts CafeCar for
   plain CRUD but hasn't run the sessions migration is one unauthorized request away from a 500.

4. **The sessions generator is incomplete and its USAGE is false** (see row 15). There is no
   supported one-command path to set auth up.

5. **No password reset / signup in the engine.** The dummy has a `PasswordsController` +
   `PasswordsMailer`, but those live in `test/dummy`, are app-level, and are internally inconsistent
   (`passwords_controller.rb` queries `email_address` / `find_by_password_reset_token!` while the
   `User` model normalizes `email`). None of this ships in the gem.

6. **Entirely undocumented.** README never mentions sessions/auth as a feature (its only auth mention
   is Pundit *authorization*). This is a hidden, half-baked subsystem — exactly the "ship half-baked
   features" pattern this audit exists to stop.

**Recommendation for v1:** pick one —
- **(A) Cut/quarantine:** decouple `Authentication` from the mandatory `Controller` include (make it
  opt-in), label sessions "experimental" in docs, and stop the USAGE from lying. Lowest risk.
- **(B) Finish it:** ship engine session routes, complete the sessions generator (model + policy +
  a `User`/`has_secure_password` story), document the required host contract, decouple it from CRUD,
  and add coverage for logout + the unauthorized-redirect path. Larger effort.

Given this is the #1 stability priority and the source of the recent churn, **(A) for 1.0** is the
honest call; pursue **(B)** for a later minor.

---

## README accuracy (false-advertising findings)

1. **`f.field(:price).errors`** (README "Custom field rendering") — no such method; it is `error`
   (singular), `lib/cafe_car/field_builder.rb:20`. A reader copy-pasting the docs gets a `NoMethodError`.
2. **`normalized_sort_key()`** (README "In models") — actual method is `normalize_sort_key`
   (`lib/cafe_car/model.rb:14`) and it is an internal helper, not advertised public API.
3. **Sessions generator USAGE** claims it creates `app/models/session.rb` + `app/policies/session_policy.rb`;
   it creates only the migration (`lib/generators/cafe_car/sessions/sessions_generator.rb:6-8`).
4. **Undocumented auth subsystem** — a whole sessions/Current/authentication stack ships in `app/`
   but appears nowhere in the README. (Inverse of false advertising, same trust problem: surprise
   coupling.)
5. **Minor:** README install list ("bcrypt, paper_trail, factory_bot_rails, faker, rouge") omits the
   extra gems the install generator actually injects (`cnc` from GitHub + 5 dev gems) —
   `install_generator.rb:7-20`.

---

## Committed v1 surface

**Commit to at 1.0 (IN):**
- Auto-CRUD controller (`cafe_car`)
- Pundit authorization (policies, scopes, attribute permissions)
- Filtering / query DSL
- Current context
- Generators: `resource`, `controller`, `policy`, `notes`
- View overriding

**Ship but label "needs hardening / lightly tested" (NEEDS-WORK — close gaps first):**
- Presenters (works; almost no direct tests)
- UI components (works via fallback; uneven Ruby coverage of advertised set)
- Forms / form builder (works; doc fix needed)
- Pagination & sorting (works; doc fix + a test)
- Turbo Streams (templates exist; unverified)
- JSON responses (unverified)
- `install` generator (untested, mutates Gemfile)

**Experimental / cut from 1.0 marketing (OUT/EXPERIMENTAL):**
- Auth / Sessions subsystem
- `sessions` generator

---

## Must-fix before v1 (prioritized — feeds fix-halfbaked-features)

1. **Resolve auth/sessions** (Auth row 16 + generator row 15). Decouple `Authentication` from the
   mandatory `Controller` include so a CRUD-only host can't 500, and either label it experimental or
   finish the wiring. Highest priority — it's the churn source and a latent 500.
2. **Fix the sessions generator USAGE / make it do what it claims** (or delete it for v1). Lying
   generator output is a direct trust killer.
3. **README accuracy pass:** `error` not `errors`; drop/rename `normalized_sort_key`; either document
   or explicitly de-scope auth; reconcile the install-generator gem list.
4. **Add the missing generator tests** — `install`, `resource`, `controller`, `notes` are uncovered
   (install/notes test files are literally empty stubs). The Gemfile-mutating `install` generator is
   the scariest untested path.
5. **Add coverage for advertised-but-unverified response formats:** a `turbo_stream` request test and
   a `json` request test, plus at least one direct presenter rendering test and one sort/paginate test.
   These features are marketed "out of the box" with no proof they work.

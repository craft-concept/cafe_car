# Design proposal — dashboards & bulk actions via views/partials (not config DSLs)

Status: **SHIPPED (2026-07-03).** Owner approved with corrections (`DECISIONS.md`, top entry): the
POLICY is the source of truth — `permitted_bulk_actions` / `permitted_metrics` drive the UI by
default, overridden explicitly by a host view; button styles come from the locale; all copy in
locales. Both DSLs (`CafeCar.bulk_action`, `CafeCar.dashboard`) and their classes are removed. See
the "What shipped vs. the proposal" note at the end for the resolved open questions.

## Why

Owner direction, 2026-07-03 (`DECISIONS.md`, top entry):

> "Absolutely no config DSLs for dashboards or bulk actions. Like everything else they should be
> configured via views and partials."

> "CafeCar is not an admin framework or a CRUD generator. It is an extension of rails' view and
> controller layer. Convention over configuration… a composable view extension for rails… just how
> I think rails should work out of the box."

Two shipped features configure through Ruby DSLs in an initializer, which is exactly the shape the
owner ruled out. This note proposes moving both onto CafeCar's **existing** view/partial
convention. The owner still wants the *features* ("now also dashboards!") — this reworks the
*mechanism*, not the capability.

---

## The existing convention (the thing we must follow, not reinvent)

CafeCar already has one way a host customizes UI, and it is entirely views + partials + helpers.
Three pillars, all present in the code today:

**1. Defaults live in `app/views/application/`; a host overrides by dropping a template at the
matching resource path.** The engine ships default templates under `app/views/application/`
(`_index`, `_table`, `_show`, `_form`, `_search`, `_bulk_actions`, `_chart`, …). Because every
CafeCar controller descends from `ApplicationController`, Rails view lookup falls back to
`application/` and a host wins by placing a file in its resource's own directory. `README.md`
(lines 653-666):

> Override default views by creating templates in your application:
> `app/views/products/index.html.haml` … `_form.html.haml`. CafeCar's default views … serve as
> templates.

The dummy app demonstrates it: `test/dummy/app/views/articles/index.html.haml`,
`articles/_index.html.haml`, `articles/_body.html.haml` all override the `application/` defaults.
The controller wires the fallback in `lib/cafe_car/controller.rb:51-54` (`append_cafe_car_views`).

**2. A view composes with CafeCar helpers + UI components — the view *is* the config surface.**
Host-authored templates call view helpers and components rather than reading config. From
`test/dummy/app/views/articles/show.html.haml`:

```haml
= Page :slim, :center do |page|
  = page.Body do
    %article
      %h1= title
      %h2= p.show :author
      = p.show :body
```

`Page`, `page.Body`, `Article(...)`, `Button(...)` resolve through `Helpers#method_missing` →
`ui.send` (any capitalized method is a UI component — `lib/cafe_car/helpers.rb:214-217`).
Data-shaping helpers already live alongside them: `table_for`, `chart_for`, `filter_form_for`,
`present`/`p`, `paginate`, `page_entries_info` (`lib/cafe_car/helpers.rb:150-158`).

**3. New components are partials, not registrations.** `README.md:441-455` — a custom component is
just a partial at `app/views/cafe_car/ui/_badge.html.haml`, invoked as `ui.Badge`. Nothing is
registered in Ruby.

So the north star for both reworks: **presence of a conventional template = opt-in; the template
body calls helpers/components; per-resource partials are the override points; behavior that needs
a method lives on the model or policy, not in an initializer block.**

---

## Current state of the two features

### Dashboards (Pass 90, commit 3fed953)

- `CafeCar.dashboard do metric(...); chart(...) end` in an initializer builds a `Dashboard`
  (`lib/cafe_car/dashboard.rb`) holding `Metric`/`Chart` widget structs.
- `lib/cafe_car.rb:83-104`: `dashboard_config` mattr, the `.dashboard` declare/fetch method, and
  `.dashboard?`.
- Route mounts only `if CafeCar.dashboard?` (`config/routes.rb:13-19`).
- `DashboardsController#show` 404s unless `CafeCar.dashboard?`; the view iterates
  `CafeCar.dashboard.widgets` rendering `dashboards/_metric` / `_chart`
  (`app/views/cafe_car/dashboards/show.html.haml`).
- Nav link gated on `CafeCar.dashboard?` (`lib/cafe_car/navigation.rb:52-53`).

### Bulk actions (commit ce5d6fe)

- `CafeCar.bulk_action(:publish) { … }` builds a `BulkAction` (`lib/cafe_car/bulk_action.rb`) into
  the `CafeCar.bulk_actions` registry (`lib/cafe_car.rb:62-78`). Default `apply` is `record.<name>!`;
  default `query` predicate is `<name>?`.
- The `bulk_actions` helper filters the registry by the model's policy
  (`lib/cafe_car/helpers.rb:159-168`); `_bulk_actions` renders a button per action
  (`app/views/application/_bulk_actions.html.haml`).
- `Controller#batch` looks the action up in the registry, narrows to the policy scope, authorizes
  **each record** with `action.allowed?(policy(record))`, then `action.apply(record)`
  (`lib/cafe_car/controller.rb:113-122`). Per-record authorization is the security boundary.

Notably, both DSLs already **default to model/policy conventions** — `bulk_action(:publish)` means
`publish!` + `publish?`, and a metric is just a callable. The DSL mostly restates conventions the
host could express directly. That is what makes this rework a simplification, not a feature loss.

---

## Proposal A — Dashboards as a view

A host defines a dashboard by **writing one template**, exactly like overriding any other view. Its
existence is the opt-in (no template → no dashboard, mirroring today's "no widgets → no route").

### What the host writes

```haml
-# app/views/cafe_car/dashboard/show.html.haml
-# Writing this file IS the dashboard. Delete it and the dashboard is gone.
- title "Dashboard"

= Page title: "Dashboard" do |page|
  = page.Body do
    .Dashboard
      = metric("Users")         { User.count }
      = metric("Signups today") { User.where(created_at: Date.current.all_day).count }
      = chart "New users", model: User, x: :created_at, by: :month
```

Everything the old DSL expressed is here, but as helper calls in a template the host owns — same
shape as `articles/show.html.haml` above. The `metric` value is a plain block evaluated at render
(host-authored, so trusted, just as the DSL's callable was). The host can drop any markup between
tiles, add headings, split into `.DashboardRow`s, `render` their own partials — because it is a
real view, not a widget list.

### What CafeCar provides

- **Two helpers** in `CafeCar::Helpers`, replacing the widget structs:
  - `metric(label, &block)` — renders the existing `_metric` tile with `label` + `capture(&block)`
    as the value. (The `Dashboard::Metric` struct and its `_metric` partial collapse into this.)
  - `chart(title, model:, x:, by: nil)` — renders the existing `_chart` tile, building the SVG via
    the **unchanged** `chart_for` / `ChartBuilder` with `column: x, bucket: by`. The date-column
    allowlist in `ChartBuilder#columns` still gates `x`, so a bad column can never reach SQL — the
    security property from `dashboards/_chart.html.haml:2-4` is preserved verbatim.
- **The controller** (`DashboardsController#show`) keeps skipping the CRUD policy pipeline (it has
  no model, like the components gallery) and renders `cafe_car/dashboard/show`. Instead of the
  `CafeCar.dashboard?` config predicate, opt-in is decided by whether the host template exists —
  the helpers already expose this (`Helpers#partial?` / `template_glob`,
  `lib/cafe_car/helpers.rb:190-204`), and Rails' `template_exists?` does it in the controller. No
  host template → `head :not_found`.
- **Nav link**: `Navigation#dashboard_href` returns the path only when the dashboard template
  exists (swap `CafeCar.dashboard?` for a `template_exists?` check), so an unconfigured host still
  gets no dashboard link.

### The one real wrinkle — route mounting (open question O1)

Today the route is drawn `if CafeCar.dashboard?`. Routes are drawn at boot, before any view
context, so we can't ask the *rendered* template. Two ways to keep "no template → no route":

- **A1 (recommended): always mount `get "dashboard"`, let the controller 404 when the host template
  is absent** (`template_exists?("cafe_car/dashboard/show")`). Simplest; opt-in is preserved at
  every *visible* surface (no nav link, 404 on direct hit). The only cost is a route that resolves
  to a 404 — invisible to users and harmless.
- **A2: keep a conditional mount by globbing the filesystem at boot**
  (`Rails.root.join("app/views/cafe_car/dashboard/show.*").exist?`). Faithful to "route only when
  opted in," but couples `routes.rb` to a filesystem glob and to code-reload ordering.

Recommendation: **A1** — it matches how the components gallery mounts unconditionally and lets the
controller own visibility. Owner to confirm.

---

## Proposal B — Bulk actions as a partial + model/policy conventions

A bulk action is fundamentally three things the host already writes in idiomatic Rails: **a button
(view), a model bang method (behavior), and a policy predicate (authorization).** The registry adds
nothing a convention can't derive — so we delete it and drive everything off the action name.

### What the host writes

**1. The buttons — override the resource's `_bulk_actions` partial** (same override mechanism as any
other partial; the `application/_bulk_actions` default can ship the common `:destroy`):

```haml
-# app/views/cafe_car/articles/_bulk_actions.html.haml
= bulk_action :publish
= bulk_action :archive
= bulk_action :destroy, :danger
```

**2. The behavior — a bang method on the model** (plain Rails, where behavior belongs):

```ruby
class Article < ApplicationRecord
  def publish! = update!(published_at: Time.current)
  def archive! = update!(archived_at: Time.current)
end
```

**3. The authorization — a predicate on the policy** (the Pundit surface the host already writes):

```ruby
class ArticlePolicy < ApplicationPolicy
  def publish? = user.editor?
  def archive? = user.editor?
end
```

This is *exactly* what `bulk_action(:publish) { update!(published_at: …) }` decomposed into — we
just put each piece in its conventional home instead of an initializer block. A custom-behavior
action (the old block form) becomes a named model method, which is cleaner and testable on its own.

### What CafeCar provides

- **A `bulk_action(name, *flags)` view helper** replacing the registry loop in `_bulk_actions`. It
  renders the submit button wired to `BulkForm` (the wiring already in
  `application/_bulk_actions.html.haml:6-10`), shown only when the model's policy grants `name?`
  (`policy(model.new).public_send("#{name}?")`) — preserving today's "only show buttons the policy
  allows" behavior. Flags (`:danger`) pass through to the component.
- **`Controller#batch` derives everything from the action name** — no registry lookup:

  ```ruby
  def batch
    skip_authorization                       # per-record check below is the boundary
    name    = params[:bulk_action].to_s
    records = policy_scope(model).where(id: Array(params[:ids]))
    allowed = records.select { |r| policy(r).respond_to?("#{name}?") && policy(r).public_send("#{name}?") }
    allowed.each { |r| r.public_send("#{name}!") }
    redirect_to url_for(action: :index), success: batch_notice(name, allowed.size)
  end
  ```

  The per-record `policy(r).<name>?` check is unchanged as the security boundary (it *is*
  `BulkAction#allowed?`, inlined). Rows the user can't act on are still skipped, never bulk-bypassed.

### The whitelist question (open question O2)

Deriving the action from `params` means the request names the method. The per-record policy
predicate already bounds it — a POST of `bulk_action=delete_everything` is dropped unless the policy
answers `delete_everything?` truthy *and* the model responds to `delete_everything!`. That is a real
gate, but it's implicit. Two ways to make the permitted set explicit and view/policy-driven:

- **B1 (recommended): a policy method lists the permitted actions**, e.g.
  `def bulk_actions = %i[publish archive destroy]` on the policy. `#batch` rejects any name not in
  it; the `bulk_action` helper can read it too so the view and the controller agree. This lives on
  the **policy** — the host's normal authorization layer, not a config DSL/initializer — so it fits
  the existing convention (`permitted_attributes`, `displayable_attributes` are already
  policy-authored lists).
- **B2: rely solely on the per-record predicate + model `respond_to?` gate** (no explicit list).
  Least code, but the callable set is implicit and easy to reason about wrong.

Recommendation: **B1** — explicit, policy-driven, consistent with how CafeCar already lets a policy
declare what's allowed. Owner to confirm whether a policy-level list counts as "views and partials"
or whether the button set in the partial should be the sole source of truth (harder — the controller
can't cheaply read a partial's contents).

---

## Migration sketch

**Removed**
- `lib/cafe_car/dashboard.rb` (the `Dashboard`/`Metric`/`Chart` structs).
- `lib/cafe_car.rb:80-104` — `dashboard_config`, `.dashboard`, `.dashboard?`.
- `lib/cafe_car.rb:62-78` — `bulk_actions` mattr, `.bulk_action`, and the `bulk_action :destroy`
  registration; `lib/cafe_car/bulk_action.rb` (the `BulkAction` class).
- `require "cafe_car/bulk_action"` / `require "cafe_car/dashboard"` (`lib/cafe_car.rb:7-8`).
- Any documented `CafeCar.dashboard`/`CafeCar.bulk_action` initializer snippets.

**Added / changed**
- `Helpers#metric`, `Helpers#chart` (dashboard tile helpers); `Helpers#bulk_action` (button helper);
  rework `Helpers#bulk_actions?` to mean "does this policy grant any listed bulk action."
- Move `app/views/cafe_car/dashboards/*` → a `cafe_car/dashboard/show` default (or ship only the
  `_metric`/`_chart` tile partials the helpers render; the host authors `show` themselves).
- `DashboardsController#show`: opt-in via `template_exists?` instead of `CafeCar.dashboard?`.
- `config/routes.rb`: mount per O1 (recommend always-mount + controller 404).
- `Navigation#dashboard_href`: gate on template existence.
- `Controller#batch`: derive action from name, drop registry lookup (per O2, add a policy
  `bulk_actions` list).
- Default `application/_bulk_actions`: render `= bulk_action :destroy, :danger` via the new helper.
- Dummy app: replace the initializer DSL usage with a `cafe_car/dashboard/show.html.haml` and (if
  present) any `CafeCar.bulk_action` calls with model methods + a `_bulk_actions` partial. **Not in
  this pass** — the dummy app is off-limits until the rework is greenlit.
- Tests: the dashboard controller/chart tests and any bulk-action tests move from asserting on the
  registry to asserting on the rendered template + `#batch` name-derivation.

**Preserved unchanged**
- `ChartBuilder` and its date-column allowlist (dashboards reuse it as-is).
- Per-record authorization as the bulk boundary (`policy_scope` + per-record predicate).
- Opt-in semantics (no template → no dashboard, no visible route, no nav link).
- The `_bulk_actions` button wiring to `BulkForm`.

---

## Open questions for the owner

- **O1 — dashboard route mount.** Always mount `get "dashboard"` and 404 when the host template is
  absent (A1, recommended), or keep a boot-time filesystem glob to mount only when the template
  exists (A2)?
- **O2 — bulk-action whitelist.** Is a policy method (`def bulk_actions = %i[…]`, B1, recommended)
  an acceptable "not a config DSL" home for the permitted-action list, or must the *only* source of
  truth be the button set in the `_bulk_actions` partial (B2)? B2 needs a way for `#batch` to learn
  the permitted names without reading a rendered partial — genuinely harder; guidance wanted.
- **O3 — where the dashboard template lives.** `app/views/cafe_car/dashboard/show.html.haml`
  (proposed, matches the `cafe_car/` override root in `append_cafe_car_views`) vs. a top-level
  `app/views/dashboard/show.html.haml`. Former keeps CafeCar's surfaces namespaced; confirm.
- **O4 — `metric` value: block vs. lambda.** `metric("Users") { User.count }` (proposed, matches
  CafeCar's block-taking component style) vs. keeping the DSL's `-> { }` lambda form. Cosmetic.
- **O5 — scope creep check.** The same email flagged re-examining `CafeCar.theme=` against
  "no config DSLs." `theme=` is a single scalar setting, not a builder DSL — treat separately, or
  fold into this rework? (Recommend separate; it's a different shape of question.)

---

## What shipped vs. the proposal (2026-07-03)

Resolved per the owner's approval-with-corrections:

- **O1 — dashboard route mount → A1.** The route always mounts (`get "dashboard"`); the controller
  404s unless the host wrote `app/views/cafe_car/dashboard/show.html.haml`. Template existence is
  the opt-in, checked with `template_exists?("show", %w[cafe_car/dashboard], false)` — resolved via
  the host's `app/views` (the engine ships no `show`, only the `_metric`/`_chart` tile partials).
- **O2 — bulk-action whitelist → B1, on the policy.** `Policy#permitted_bulk_actions` (default
  `%i[destroy]`) is the source of truth. The `_bulk_actions` partial **loops that list by default**
  via a `bulk_action` view helper; overriding the partial is the explicit opt-out. `Controller#batch`
  derives `name?` (per-record authorization, unchanged security boundary) and `name!` (model bang
  method) from the action name and rejects any name outside the policy list as a bad request.
- **Metrics are policy-driven too** (owner correction): `Policy#permitted_metrics` (default `[]`,
  a list of model scope names; `:all` = the whole relation) drives the `metrics` view helper, which
  renders a count tile per entry. A host template overrides by calling `metric`/`chart` directly.
- **Button styles from the locale** (owner correction): `bulk_actions.styles.<name>` maps an action
  to a Button flag (shipped default `destroy → danger`). All labels/copy live in `config/locales`.
- **`metric` / `chart` helpers** replace the widget structs, composing the unchanged `ChartBuilder`
  and its date-column allowlist. The chart aspect-ratio polish (owner: "narrow and tall") shipped
  alongside as a `ChartBuilder` geometry change.

**Removed:** `lib/cafe_car/bulk_action.rb`, `lib/cafe_car/dashboard.rb`, the `CafeCar.bulk_action`
registry + `CafeCar.dashboard` DSL + `dashboard_config` (all of `lib/cafe_car.rb`'s DSL block), the
`cafe_car/dashboards/` views, and the dummy app's `cafe_car_dashboard.rb` initializer.

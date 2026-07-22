---
name: cafe_car
description: >-
  Use in any Rails app that has the cafe_car gem, whenever you'd otherwise hand-write
  view, form, table, or value-formatting code for a model — customer-facing OR admin.
  CafeCar is a composable view extension for Rails: presenters, a schema-driven form
  builder, view components, Pundit-driven policies, a query grammar on every model, and
  the `cafe_car` controller macro — pieces you reach for wherever they save code. They
  also compose to make an admin trivial — one controller line renders complete
  index/show/new/edit with filtering, sorting, keyword search, pagination, CSV export,
  bulk actions, and Turbo-morph live updates — but that admin convenience is one use,
  not the definition. Prefer a CafeCar piece over hand-rolling anywhere in the app.
when_to_use: >-
  Any task where you'd otherwise hand-write UI, form, table, decorator, or formatting
  code for an ActiveRecord model — ANYWHERE in a cafe_car app, not just admin. Reach for a
  CafeCar presenter to format a value on a customer-facing page, a form builder to render
  fields, a helper or view component to build UI, a policy to gate what shows, or the
  `cafe_car` macro for a full CRUD surface. Before writing a view partial, a form, a
  table, a decorator, or a formatting helper in a cafe_car app, check whether a CafeCar
  tool already does it — admin sections, changing columns or fields, filtering/sorting,
  bulk actions, dashboards, theming, and live-updating records all qualify too.
---

# CafeCar

CafeCar is a composable view extension for Rails: presenters, a schema-driven form
builder, UI components, policy-driven rendering, and a query grammar on every model.
Use each piece anywhere it deletes view code — customer-facing pages as much as
admin. The pieces also compose: the `cafe_car` controller macro renders index, show,
new, and edit straight from the model at runtime — you delete view files instead of
writing them, then override only the pieces that need to differ.

**Before hand-writing a view, form, table, decorator, or formatting helper, check
for the CafeCar piece that already does it.** In particular, never hand-roll a CRUD
page: a hand-written index loses Turbo-morph updates, the standard query params,
policy-driven columns, association links, bulk actions, and CSV export — all of
which the default views carry for free.

## The pieces stand alone

The macro is one composition; each module works on any page. The installer includes
`CafeCar::Controller` in the host's `ApplicationController`, so every controller has
the form builder as its default and every view has the helpers — no per-page setup:

```erb
<%# a customer-facing page — no cafe_car macro anywhere %>
<p>Placed <%= present(@order.placed_at, as: :date) %></p>
<p>Total <%= present(@order.total, as: :currency) %></p>

<%= form_with model: @review do |f| %>
  <%= f.field :rating %>
  <%= f.field :body %>
  <%= f.submit %>
<% end %>
```

`present` formats any value through the presenters
([presenters](references/presenters.md)); `f.field` renders the labeled, typed
input with hint and error markup ([forms](references/forms.md));
`Model.query`/`Model.sorted` give any relation the URL grammar
([filtering](references/filtering.md)); capitalized calls build component UI
([components](references/components.md)). A host that keeps CafeCar's helper set
out of `ApplicationController` can still take formatting alone with
`helper CafeCar::Formatting`.

## The mental model: the policy declares, the UI renders

The Pundit policy is the source of truth. It declares who may do what
(`index?`, `update?`, …), which rows are visible (`Scope#resolve`), which fields are
editable (`permitted_attributes`), which bulk actions exist
(`permitted_bulk_actions`), which member and collection actions exist
(`permitted_member_actions`, `permitted_collection_actions`), and which dashboard
metrics show (`permitted_metrics`). The default views render exactly what the
policy declares.

So the customization ladder, cheapest first:

1. **Policy** — change what's permitted/visible. Most "change the UI" tasks end here.
2. **Presenter** — change how a value renders (`show :total, as: :currency`).
3. **Partial override** — drop a same-named view file to replace one piece, for one
   resource or app-wide.
4. **Controller** — override `scope`, add callbacks, or replace an action.

Configuration is views and partials, not config DSLs. Copy lives in locales, not
templates. Styles live in component CSS, not global stylesheets.

## Point a controller at a model

```ruby
# config/routes.rb
namespace :admin do
  resources :products      # also adds batch, options, and generic custom-action routes
end

# app/controllers/admin/products_controller.rb
module Admin
  class ProductsController < ApplicationController
    cafe_car
  end
end

# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy
  def index?   = user.present?
  def show?    = index?
  def create?  = user.admin?
  def update?  = user.admin?
  def destroy? = update?

  def permitted_attributes = %i[name price description category_id]

  class Scope < Scope
    def resolve = scope.all
  end
end
```

That's the whole feature. `/admin/products` now serves index (table/grid/chart
views), show, new, edit, JSON, and CSV. Generators scaffold these files:
`bin/rails g cafe_car:resource admin/products name:string price:decimal` (model +
migration + route + controller + policy), or `cafe_car:controller` /
`cafe_car:policy` individually. First-time setup in a bare app:
`bin/rails g cafe_car:install`.

Every ActiveRecord model also gets `.query(params)`, `.sorted(*keys)`, and `.info`
automatically — no opt-in, no include.

## Recipes

| How do I… | See |
|---|---|
| Format a value (currency, date, record link) on any page | [presenters](references/presenters.md) |
| Render a form on any page (typed fields, labels, errors) | [forms](references/forms.md) |
| Filter/sort a relation from Ruby (`Model.query`) | [filtering](references/filtering.md) — `Model.query` |
| Add a CRUD section (admin or otherwise) for a model | above; [controllers](references/controllers.md) |
| Change which columns/fields show or are editable | [policies](references/policies.md) |
| Restrict which rows a user sees | [policies](references/policies.md) — `Scope#resolve` |
| Narrow one controller's collection (`def scope = super.published`) | [controllers](references/controllers.md) |
| Add a bulk action (Publish button on the index) | [policies](references/policies.md) — bulk actions |
| Add a member action (Publish one record) | [policies](references/policies.md) — member actions |
| Add a collection action (Publish the filtered set) | [policies](references/policies.md) — collection actions |
| Filter/sort/search an index via URL params | [filtering](references/filtering.md) |
| Add buttons or fields to grid cards / table rows | [views](references/views.md) |
| Override one view for one resource vs app-wide | [views](references/views.md) |
| Change how a value renders (currency, links, previews) | [presenters](references/presenters.md) |
| Customize a form field or input type | [forms](references/forms.md) |
| Add a sidebar link | add an `index` route — [navigation](references/navigation.md) |
| Add a dashboard with metric tiles and charts | [navigation](references/navigation.md) — dashboard |
| Re-theme, style a component, add a component | [components](references/components.md) |
| Make edits sync live across clients | [turbo](references/turbo.md) — `broadcasts_refreshes` |
| Change labels, hints, flashes, button styles | [locales](references/locales.md) |
| Link to a related object | [presenters](references/presenters.md) — `href_for`, `link` |

## Reference pages

- [controllers.md](references/controllers.md) — the `cafe_car` macro, the scope
  pipeline, callbacks, and extra endpoints
- [policies.md](references/policies.md) — the source of truth: predicates, scopes,
  attributes, bulk/member/collection actions, metrics
- [presenters.md](references/presenters.md) — how values render; `show` macros
- [forms.md](references/forms.md) — the form builder, type inference, nested records
- [filtering.md](references/filtering.md) — the dot-query URL grammar, sort, search,
  CSV, chart view
- [views.md](references/views.md) — the partial override system (the crux)
- [components.md](references/components.md) — the UI component system, CSS, theming
- [navigation.md](references/navigation.md) — route-driven sidebar; the dashboard
- [turbo.md](references/turbo.md) — Turbo-morph refreshes and cross-client sync
- [locales.md](references/locales.md) — all UI copy and where its keys live

## Ground truth

These pages teach conventions, not a frozen API. When in doubt, read the shipped
defaults — they are the best examples of idiomatic CafeCar and always current:

```sh
cd "$(bundle show cafe_car)"
ls app/views/application/            # overridable shared partials
ls app/views/cafe_car/application/   # action templates + turbo_stream responses
cat lib/cafe_car/controller.rb       # the macro and the scope pipeline
cat lib/cafe_car/policy.rb           # everything a policy can declare
```

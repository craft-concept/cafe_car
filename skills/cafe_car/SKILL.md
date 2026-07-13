---
name: cafe_car
description: >-
  Use when building admin, back-office, index, or CRUD UI in a Rails app that has the
  cafe_car gem: point a controller at a model (the `cafe_car` macro) and the Pundit
  policy drives complete index/show/new/edit pages — filtering, sorting, keyword search,
  pagination, CSV export, bulk actions, and Turbo-morph live updates included. Do not
  hand-roll admin controllers or views in these apps; extend CafeCar's defaults.
when_to_use: >-
  Any task touching list/detail/form UI for an ActiveRecord model in an app with
  cafe_car in the Gemfile: adding an admin section, changing visible columns or fields,
  restricting access, filtering or sorting an index, adding buttons to cards or rows,
  bulk actions, dashboards, theming, or live-updating records across clients.
---

# CafeCar

CafeCar is a composable view extension for Rails. It renders index, show, new, and
edit straight from the model at runtime — you delete view files instead of writing
them. One controller line gives you the whole CRUD surface; you then override only
the pieces that need to differ.

**Never hand-roll an admin page in a CafeCar app.** A hand-written index loses
Turbo-morph updates, the standard query params, policy-driven columns, association
links, bulk actions, and CSV export — all of which the default views carry for free.

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
| Add an admin section for a model | above; [controllers](references/controllers.md) |
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

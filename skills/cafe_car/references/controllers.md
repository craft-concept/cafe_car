# Controllers

Source: `lib/cafe_car/controller.rb` (the `CafeCar::Controller` concern — usually
included in the host's `ApplicationController` by the installer).

## The macro

```ruby
module Admin
  class ProductsController < ApplicationController
    cafe_car
  end
end
```

`cafe_car` wires the full CRUD surface: `index show new edit create update destroy`,
plus `batch` (bulk actions) and `options` (association-select typeahead JSON). It
authorizes every action through Pundit (`verify_authorized` and
`verify_policy_scoped` are enforced), responds to `:html`, `:json`, `:turbo_stream`,
and `:csv`, rescues validation failures into a re-rendered form, and appends the
engine's view fallbacks.

The model is inferred from the controller name (`Admin::ProductsController` →
`Product`). Variants:

```ruby
cafe_car only: %i[index show]          # limit actions
cafe_car except: %i[destroy]
cafe_car model: Company                # or the standalone `model Company` macro

class AttachmentsController < ApplicationController
  cafe_car
  model ::ActiveStorage::Attachment    # point at any model, even a library's
  default_view :grid                   # index defaults to grid instead of table
end
```

## The scope pipeline

Every action reads records through one method:

```ruby
def scope = model.all.then { policy_scope _1 }
                     .then { sorted _1 }
                     .then { filtered _1 }
                     .then { eager_loaded _1 }
                     .then { paginated _1 }
```

`policy_scope` applies the policy's `Scope#resolve`; `sorted` reads `?sort=`;
`filtered` reads the dot-query params and `?q=`; `eager_loaded` preloads displayed
associations (no N+1); `paginated` is Kaminari (`?page=`, `?per=` capped at
`CafeCar.max_per_page`). CSV requests skip pagination and export the whole
filtered set.

Narrow one controller without touching the policy:

```ruby
class Admin::PublishedArticlesController < ApplicationController
  cafe_car model: Article
  def scope = super.published
end
```

Prefer the policy `Scope` when the restriction is about *who may see what*; override
`scope` when it's about *what this particular screen lists*.

## Objects and callbacks

`object` / `objects` are the current record/collection, also exposed as the
conventional ivars (`@product`, `@products`). Lifecycle callbacks exist for
`:create`, `:update`, `:destroy`, and `:render`:

```ruby
class ProductsController < ApplicationController
  cafe_car

  after_create do
    NotificationMailer.product_created(object).deliver_later
  end
end
```

(`before_`/`around_`/`after_` + `skip_*` helpers are defined for each; blocks run in
controller context around `object.save!` / `object.destroy!`.)

## Extra endpoints

Host routes drawn with `resources` automatically gain two collection routes
(`lib/cafe_car/routing.rb`):

- `POST /products/batch` — applies a bulk action to selected ids. The action name
  must be in the policy's `permitted_bulk_actions`; each record is authorized
  individually against `<action>?` then receives `<action>!`. See
  [policies.md](policies.md).
- `GET /products/options?q=…` — policy-scoped `[{value, text}]` JSON feeding the
  searchable association selects. See [forms.md](forms.md).

## Responses

Success responds per format: HTML redirects with a locale-driven flash
(`flashes.create_html` etc.), turbo_stream emits a page refresh (morph — see
[turbo.md](turbo.md)), JSON serializes `[:id] + attributes.displayable` per the
policy. Validation failure re-renders `new`/`edit` with `422`. Authorization failure
returns 403 — or redirects to login when the opt-in sessions are installed
(`bin/rails g cafe_car:sessions`).

# Upgrading CafeCar

Version-to-version breakage notes: what you'll see mid-upgrade, why it changed,
and the exact fix. Sections are newest first; error messages are quoted
verbatim so you can grep this file for yours. [CHANGELOG.md](CHANGELOG.md) is
the full record — this file covers only the changes that can break a host app.

## Unreleased

### CafeCar routes now come from the `cafe_car` macro, not `resources`

**What you'll see.** With a plain `resources :products` in your routes, any
index whose policy offers a bulk action (the default offers `destroy`) 500s
while rendering:

```
ActionView::Template::Error (No route matches {:action=>"batch", :controller=>"products"})
```

A direct request to a CafeCar endpoint 404s:

```
ActionController::RoutingError (No route matches [POST] "/products/batch")
```

Association selects quietly lose their typeahead — the `options` feed has no
route, so the field degrades to a plain select capped at
`CafeCar.max_collection_options`. Policy-declared custom-action buttons raise
the same `UrlGenerationError` for `:member_action` / `:collection_action`.

**Why.** CafeCar used to inject its endpoints into every host `resources`
call, so each resource gained the `batch`/`options`/custom-action routes just
from having the gem installed — and `only:`/`except:` could not filter them.
A plain `resources` now draws exactly Rails' routes; CafeCar endpoints come
only from the explicit macro.

**Fix.** In `config/routes.rb`, switch each CafeCar-backed resource:

```diff
-resources :products
+cafe_car :products
```

`only:`/`except:` narrow the CafeCar endpoints along with the RESTful seven —
`cafe_car :articles, only: %i[index show]` draws no mutating routes at all.
Leave non-CafeCar resources as `resources`; they no longer carry stray CafeCar
routes.

### Actions excluded by `only:`/`except:` respond 404

**What you'll see.** An action excluded by the controller macro
(`cafe_car only: %i[index show]`) returns `404 Not Found`. Before this change
an excluded action could crash with a raw 500:

```
RuntimeError (nothing to authorize! Define self.object or self.objects)
```

**Why.** `only:`/`except:` now gate the whole surface — the
`batch`/`options`/custom-action endpoints included — with an up-front
`head :not_found`, mirroring the routing macro not drawing excluded routes.

**Fix.** Nothing, unless you depended on an excluded action still responding:
include it in `only:` (in both the controller macro and the route).

### Host forms get Rails' `field_with_errors` wrapper back

**What you'll see.** In your app's own (non-CafeCar) forms, a field that
failed validation is wrapped in Rails' `<div class="field_with_errors">` again
— which can shift layout if your CSS never accounted for it.

**Why.** Mounting the engine used to override
`ActionView::Base.field_error_proc` globally, silently stripping the wrapper
from every form in the host app. The override is now scoped to CafeCar's own
forms; your forms keep Rails' default behavior.

**Fix.** Style `.field_with_errors`, or set your own
`config.action_view.field_error_proc` — relying on CafeCar to strip it
app-wide was the bug.

### Custom actions with no handler fail closed

**What you'll see.** A policy-permitted member/collection action whose
handler is missing (renamed, typo'd, unimplemented) is refused — rendered as a
denial, not the previous raw 500:

```
NoMethodError (undefined method 'publish!' for an instance of Product)
```

The convention path also logs when it fires:

```
[CafeCar] custom action :publish has no products#publish handler; dispatching to Product#publish! by convention — define #publish to add controller-level guards
```

**Fix.** Define the model bang method (`Product#publish!`) or a public
controller method of the action's name.

### `present` without the admin helpers

Not breakage, but a better seam: if you exposed `CafeCar::Helpers` app-wide
just for the `present` formatting helper, switch to
`helper CafeCar::Formatting`. It carries `present` without the admin-only
`link_to`/`capture`/`method_missing`/`p` overrides.

### Sessions: cookie lifetimes and rotation

With the opt-in `cafe_car:sessions` feature, sessions now expire after 30 days
absolute and two hours idle, and a successful login rotates both the CafeCar
and Rails sessions. A sign-in prompt after two idle hours is the new lifetime
working, not a regression.

### The installer no longer edits your Gemfile

`cafe_car:install` no longer adds gems to the host Gemfile. Optional features
add only what they need — `cafe_car:sessions` adds its own bcrypt dependency.

## 0.3.1

### Assigning an association requires the associated model's policy

**What you'll see.** Saving a form that assigns an association is denied —
`Pundit::NotAuthorizedError` with query `associate_author?`, rendered as
`403 Forbidden` (or a redirect back with nothing saved) — and association
selects and filter typeaheads come up empty.

**Why.** Submitted association ids — polymorphic and nested ids included —
are now enforced server-side: the associated model's policy must grant
`index?` and its Pundit scope must contain the assigned record. The select
control is no longer the authorization boundary.

**Fix.** Give each associated model a policy with `index?` and a scope:

```ruby
class AuthorPolicy < ApplicationPolicy
  def index? = user.present?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
```

### Singular JSON responses stop at scalar attributes

**What you'll see.** `GET /products/1.json` no longer includes associated
records — only the policy-displayable scalar attributes.

**Why.** Associations were serialized without their own authorization and
serialization contract.

**Fix.** Serve an association a consumer needs deliberately — its own
endpoint or a controller override — under the associated model's policy.

### The dashboard requires `DashboardPolicy#show?`

**What you'll see.** The opt-in dashboard denies access after upgrading.

**Fix.** Declare who may see it:

```ruby
class DashboardPolicy < ApplicationPolicy
  def show? = user.admin?
end
```

The built-in metric and chart helpers also aggregate over each model's policy
scope now, so a tile can show a smaller number than a raw count — that's the
scope applied.

### Unknown `?view=` values fall back

An unrecognized `view` parameter falls back to the default index view instead
of resolving a partial. `table`, `grid`, and `chart` are the shipped set.

## 0.3.0

### Leading-dot filter keys are removed

**What you'll see.** `?.name=Widget` no longer filters — the full result set
comes back.

**Why.** The documented bare-key syntax now works (`?name=Widget`,
`?price.min=10`), and the undocumented leading-dot form was removed in its
favor.

**Fix.** Drop the dot from links and bookmarks: `?.name=Widget` →
`?name=Widget`.

### `?sort=` is gated to `permitted_filters`

**What you'll see.** Sorting by a column outside the policy's
`permitted_filters` is silently ignored — the same allowlist the URL-filter
gate enforces.

**Fix.** Add the column to `permitted_filters`.

### Permit the foreign key, not the association name

**What you'll see.** An association select renders and submits, but the
assignment silently doesn't save — a normal redirect, no error, no change.

**Why.** Strong params receive the column (`client_id`), so permitting the
bare association name does nothing. The `cafe_car:resource` generator now
emits the foreign key; a policy written from older generator output may still
carry the bare name.

**Fix.**

```diff
 def permitted_attributes
-  %i[client name]
+  %i[client_id name]
 end
```

### Nested-attributes forms now persist

A form over `accepts_nested_attributes_for` used to return 200 while silently
dropping every nested row. A policy permitting `line_items_attributes: [...]`
(plus `:id` and `:_destroy`) now renders, saves, updates, and destroys those
rows. Review any policy permitting an `_attributes` key — data that was
silently dropped is now written.

## 0.2.0

### `faker` and `web-console` are no longer runtime dependencies

**What you'll see.**

```
NameError (uninitialized constant Faker)
```

in seeds or factories that leaned on CafeCar's bundle, or a missing console
panel if you relied on the transitive `web-console`.

**Fix.** Add what you use to your own Gemfile:

```ruby
gem "faker", group: %i[development test]
```

### Pundit verification is scoped to the `cafe_car` macro

Controllers that merely include `CafeCar::Controller` (for example through
`ApplicationController`) no longer 500 with
`Pundit::PolicyScopingNotPerformedError`. If you added
`skip_after_action :verify_policy_scoped` to health checks or Rails-generated
session controllers to work around it, delete the workaround.

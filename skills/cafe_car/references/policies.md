# Policies — the source of truth

Source: `lib/cafe_car/policy.rb` and `app/policies/cafe_car/application_policy.rb`
in the gem. The host's `ApplicationPolicy` subclasses `CafeCar::ApplicationPolicy`;
each model gets a `<Model>Policy` (standard Pundit naming).

The policy declares, the UI renders. Before overriding a view, check whether the
change is really a policy change — usually it is.

## Action predicates

All default to `false` (deny). `new?` follows `create?`, `edit?` follows `update?`.

```ruby
class ArticlePolicy < ApplicationPolicy
  def index?   = true
  def show?    = object.published? || edit?
  def create?  = true
  def update?  = user.admin? || object.author_id == user.id
  def destroy? = !object.published?
end
```

`object` is the record (or the class, on collection checks); `user` is the current
user. Predicates gate controller actions, and the default views hide/disable
controls the policy denies — a denied Edit link renders disabled with a
locale-driven tooltip, not hidden by hand.

## Visible rows: `Scope#resolve`

```ruby
class Scope < Scope
  def resolve = user.admin? ? scope.all : scope.where(owner: user)
end
```

Every index, CSV export, chart, bulk action, and typeahead feed passes through this
— restricting here restricts everywhere. The base `Scope#resolve` raises until you
define it.

## Editable fields: `permitted_attributes`

```ruby
def permitted_attributes = %i[name price description category_id]
```

Drives both strong parameters *and* the default form (it renders exactly these
fields, in this order). Vary by record state or action:

```ruby
def permitted_attributes
  if object.try(:new_record?) || me?
    %i[name email avatar password password_confirmation]
  else
    %i[name email avatar]
  end
end

def permitted_attributes_for_create = %i[name email owner_id]  # per-action variant
```

For associations, the parent policy decides whether the foreign key is editable,
and the associated model's `index?` permission plus policy scope decide which
records may be selected. CafeCar applies that boundary to the initial select, the
remote typeahead, and submitted ids (including nested and polymorphic ids); a
crafted id outside it is denied server-side.

Nested records permit `<assoc>_attributes` the Rails way (with `:id` + `:_destroy`
for `allow_destroy`):

```ruby
def permitted_attributes
  [ :number, :issued_on, :paid,
    line_items_attributes: [ :id, :_destroy, *policy(LineItem).permitted_attributes ] ]
end
```

## Displayed fields (derived, with explicit policy overrides)

- `displayable_attributes` — override contract for what record pages and the
  JSON/CSV bases expose. The default is permitted keys ∪ every model column,
  with foreign keys folded into associations, then `id` and names matched by
  Rails' parameter filter removed. For a custom sensitive name, use
  `def displayable_attributes = super - %i[internal_note]`.
- `listable_attributes` — override contract for the default index-table fields.
  Its default is the model fields minus `id`, timestamps, and digest columns.
  Narrow it separately (`super - %i[internal_note]`) to keep a field out of the
  default table too.
- `attributes.displayable` / `attributes.listable` — the read surfaces CafeCar
  uses for those policy declarations.
- `attributes.editable` — what the form renders, derived from `permitted_attributes`.
- `title_attribute` — the record's display name; defaults to the first displayable
  attribute. Override when wrong: `def title_attribute = :number`.
- `logo_attribute` — the attachment used as avatar/card image; defaults to the
  first listable attachment.

## Bulk actions: `permitted_bulk_actions`

Default `%i[destroy]`. A custom action is three conventional pieces — no
registration anywhere:

```ruby
# app/models/article.rb — the behavior
def publish! = update!(published_at: Time.zone.now)

# app/policies/article_policy.rb — the authorization + the list
def publish? = !object.published?
def permitted_bulk_actions = %i[publish destroy]
```

The index toolbar renders a button per listed action (label from the locale key
`en.publish`, style from `bulk_actions.styles.publish` — see
[locales.md](locales.md)). On submit, each selected record is checked against
`publish?` individually — unauthorized rows are skipped, never bulk-bypassed — then
receives `publish!`. Return `[]` to offer no bulk actions.

## Member actions: `permitted_member_actions`

Default `[]`. List a name to render it on the record's show page and index row:

```ruby
# app/models/article.rb
def publish! = update!(published_at: Time.zone.now)

# app/policies/article_policy.rb
def publish? = !object.published?
def permitted_member_actions = %i[publish]
```

CafeCar posts to `/articles/:id/actions/publish`, authorizes `publish?`, and calls
`publish!`. The predicate gates both the rendered control and the request. Labels
and styles come from `en.publish` and `actions.styles.publish`.

## Collection actions: `permitted_collection_actions`

Default `[]`. A collection action runs over the policy-scoped, filtered set shown
by the current index:

```ruby
# app/models/article.rb
def self.publish_all! = unpublished.update_all(published_at: Time.zone.now)

# app/policies/article_policy.rb
def publish_all? = user.editor?
def permitted_collection_actions = %i[publish_all]
```

CafeCar posts to `/articles/actions/publish_all`, authorizes `publish_all?` against
the model class, and calls `publish_all!` within the viewed scope. The toolbar
button carries the active filters and shows the affected count. A public controller
method named `publish_all` can replace that forwarding when the action needs a
custom query or response.

## Dashboard metrics: `permitted_metrics`

Default `[]`. Names of model scopes (`:all` = whole relation) rendered as count
tiles by the `metrics Article` dashboard helper:

```ruby
def permitted_metrics = %i[all published]
```

See [navigation.md](navigation.md) for the dashboard itself.

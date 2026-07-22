# Filtering, sorting, search

Source: `lib/cafe_car/param_parser.rb`, `lib/cafe_car/query_builder.rb`,
`lib/cafe_car/controller/filtering.rb`, `lib/cafe_car/queryable.rb`,
`lib/cafe_car/model.rb`.

On an index request, every query param that isn't a control param
(`sort page per view tab q chart_* …`) is a filter. **Never invent bespoke filter
params for an index screen — link with this grammar** and the whole pipeline (table,
grid, chart, CSV export, pagination) honors it. The same grammar is a plain Ruby
API on every model (`Model.query`, below) — use it for any filtered query, not
only CafeCar-rendered pages.

## The dot-query URL grammar

| URL | Meaning |
|---|---|
| `?name=Widget` | `name = 'Widget'` |
| `?status.eq=active` | explicit equals |
| `?price.min=10&price.max=50` | `>=` and `<=` (aliases `gte`/`lte`; also `gt`/`lt`) |
| `?created_at=2024-01-01..2024-12-31` | range (`...` = exclusive end) |
| `?tags=red,blue,green` | `IN (…)` |
| `?name!=bob` | negate any filter (`!` suffix on the key) |
| `?name~=wid` | literal substring match, case-insensitive (`~` suffix) |
| `?author=true` / `?author=false` | association exists / doesn't |
| `?line_items=3`, `?line_items.min=2` | association count |
| `?author.name~=bob` | filter through an association (nests recursively) |
| `?published=true` | call a model scope (zero-arity); with a value, the value is the argument |
| `?q=widget` | keyword search (see below) |

Datetime values parse with Chronic, so `?created_at.min=last%20week` works. Combine
freely; everything composes with `sort`, `q`, `view`, and `.csv`.

## Sorting

```
?sort=name              ascending
?sort=-price            descending
?sort=category,-price   multiple
?sort=author.name       through a belongs_to (joins automatically)
```

Keys are validated against real columns/associations — bad input is dropped, never
raw SQL. Table headers emit these links already.

## Keyword search

`?q=term` matches case-insensitively across the model's string/text columns
(parameter-filtered columns like passwords are skipped). A model overrides the
default by defining a `search` scope:

```ruby
scope :search, ->(term) { query("title~": term) }
```

## Programmatic: `Model.query`

The same engine, from Ruby — available on every model with no opt-in:

```ruby
Article.query("published" => true, "author.name~" => "bob")
Invoice.query("total.min" => 100)
Article.query(["draft term"])        # a bare string routes to search
```

Returns a relation; chain as usual.

## CSV export

Every index responds to `.csv` (the toolbar has a Download CSV button). The export
carries the current filters + sort, spans the whole result set (not just the page),
mirrors the policy's displayable columns, and is capped at
`CafeCar.csv_export_row_limit` (default 10,000; truncation sets
`X-CafeCar-Truncated: true`).

## Chart view

Every index has a third view beside table and grid:

```
?view=chart&chart_x=published_at&chart_by=month        # count per month
?view=chart&chart_x=issued_on&chart_y=sum:total        # or sum:/avg: of a numeric column
```

Buckets `day`/`week`/`month`; columns are validated against the policy's
displayable date/numeric attributes. The chart aggregates the same filtered,
policy-scoped collection the table shows, as dependency-free inline SVG.

## Filter panel

The grammar above also drives a rendered panel: the model policy's
`permitted_filters` enumerates the controls (one typed per attribute), and the
same list is the query whitelist. List a dot-path to filter through an
association:

```ruby
def permitted_filters = %i[status client.status client.owner_id]
```

Each hop is the association name; the terminal may be the far column, its enum,
or a belongs_to (`client.owner_id` ≡ `client.owner`). The control is typed by
that terminal. An undeclared path — even one naming a real far column
(`?client.owner.email=`) — is pruned before any join, exactly like an
unpermitted top-level column.

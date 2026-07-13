# Views and the override system

This is the crux of CafeCar: the gem ships default templates; a host replaces any
one of them by dropping a same-named file. You delete view files, you don't write
folders of them.

## The two engine view roots

- `app/views/application/` (in the gem) — **shared partials**: `_table`, `_grid`,
  `_form`, `_show`, `_filters`, `_navigation`, … Resolved through normal controller
  prefix fallback (every host controller inherits `ApplicationController`).
- `app/views/cafe_car/application/` (in the gem) — **action templates and
  turbo_stream responses**: `index.html.haml`, `show.html.haml`, `new`, `edit`,
  `create/update/destroy.turbo_stream.haml`.

## Precedence (first match wins)

1. `app/views/<controller_path>/…` in the host — one resource
   (e.g. `app/views/admin/products/_grid_item.html.haml`)
2. `app/views/application/…` in the host — app-wide partial override
3. `app/views/cafe_car/application/…` in the host — app-wide action-template override
4. the gem's defaults

Start by copying the gem's default (`cd "$(bundle show cafe_car)"`) and trimming.
Most defaults are 1–10 lines — the composition happens in helpers and policies, so
overrides stay small.

## The key overridable partials

| Partial | Renders |
|---|---|
| `_index` | index body: bulk-action bar, the current view, result count, pagination |
| `_table` | the table: `table_for` with select/logo/title/remaining/timestamps/controls columns |
| `_grid` / `_grid_item` | card grid; `_grid_item` is one card |
| `_show` | show-page body: remaining attributes + associations |
| `_form` / `_fields` | the form card; `_fields` is just `f.remaining_fields` |
| `_field`, `_<type>_field` | one form field (see [forms.md](forms.md)) |
| `_controls` | the show/edit/delete link cluster on rows and cards |
| `_filters`, `_<type>_filter` | the index search/filter panel and its typed controls |
| `_bulk_actions` | the bulk-action button bar (defaults to looping the policy's list) |
| `_navigation`, `_navigation_links` | the sidebar (see [navigation.md](navigation.md)) |
| `_index_actions` | index toolbar right side: view toggles, CSV, New button |
| `_head` | the `<head>`: meta, stylesheets, importmap |
| `_alerts`, `_errors`, `_empty`, `_submit` | flash messages, form errors, empty state, submit row |

## Worked example: buttons on the grid cards

The gem's whole `_grid_item.html.haml`:

```haml
= Card title: object.title, image: object.logo(href: object), actions: object.controls
```

`object` is a presenter. To add a field and a custom button for one resource:

```haml
-# app/views/admin/products/_grid_item.html.haml
= Card title: object.title, image: object.logo(href: object), actions: object.controls(actions: false) do |card|
  = card.Section object.show(:price)
  = card.Foot do
    = link(object).action(:restock, class: ui.Button(:primary).class_name)
```

Declare `:restock` in the policy's `permitted_member_actions`, add `restock?` to
the policy and `restock!` to the model. Passing `actions: false` keeps the default
control cluster from rendering the same action, so this override can move it into
the card foot. The generic route and controller forwarding already ship; the label
goes in the locale. Drop the same file in `app/views/application/` to change every
resource's card.

## Worked example: a bespoke index

```haml
-# app/views/articles/index.html.haml — replaces the whole action template
= Page :slim, :center do |page|
  = page.Body do
    - @articles.each do |article|
      %article
        %h2= p article
        %p= article.summary
    = paginate @articles
```

Full control, and you keep the layout, filtering, pagination, and helpers. Prefer
overriding the smallest partial that's wrong (`_grid_item`, not `index`).

## Turbo_stream templates

Per-resource turbo responses override the same way:
`app/views/admin/products/update.turbo_stream.haml` replaces the default
morph-refresh response for that resource. See [turbo.md](turbo.md).

## Design rules (owner-set, hold to them)

- Configuration happens **in views and partials** (plus the policy) — never invent
  a config DSL or initializer registry.
- **All copy in locales** — no hardcoded UI strings in templates
  ([locales.md](locales.md)).
- **No global CSS** — styles belong to components ([components.md](components.md)).

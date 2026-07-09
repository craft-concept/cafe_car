# Navigation and the dashboard

Source: `lib/cafe_car/navigation.rb`, `app/views/application/_navigation.html.haml`
and `_navigation_links.html.haml` (in the gem).

## The sidebar is route-driven — there is no menu registry

The sidebar lists every named `index` route in the app (Rails internals excluded),
grouped by namespace (`admin/…` routes render under an "Admin" heading). So:

- **Add a sidebar link:** add `resources :things` to the routes. That's it.
- **Remove one:** don't draw an index route (`resources :things, except: :index`
  or `only:` what you need).

The current page's link highlights automatically (`current`/`ancestor` classes).

## Icons come from the locale

`navigation.icon.<controller_name>` maps a controller to an
[Iconoir](https://iconoir.com) icon name:

```yaml
en:
  navigation:
    icon:
      products: box-iso
      invoices: page-flip
```

No key, no icon — the link still renders.

## Customizing

Override the partials like any other ([views.md](views.md)):

- `app/views/application/_navigation.html.haml` — the whole sidebar (dashboard
  link, route links, session link).
- `app/views/application/_navigation_links.html.haml` — just the grouped route
  list; the `navigation` helper exposes `navigation.groups` / `navigation.routes`.
- A per-resource `_navigation.html.haml` changes (or, if empty, hides) the sidebar
  for that resource's pages only.

## The dashboard — opt in by writing one view

No template, no dashboard: the route always exists, but it 404s and shows no nav
link until the host writes `app/views/cafe_car/dashboard/show.html.haml`:

```haml
- title "Dashboard"

= Page title: "Dashboard" do |page|
  = page.Body do
    .Dashboard
      = metrics Article
      = metric("Signups today") { User.where(created_at: Date.current.all_day).count }
      = chart "New articles", model: Article, x: :created_at, by: :month
```

- `metrics(Model)` — one count tile per scope named in the model policy's
  `permitted_metrics` (`:all` = whole relation). Policy-driven; the default choice.
- `metric("Label") { … }` — one tile with whatever the block returns.
- `chart "Title", model:, x:, by:` — the inline-SVG bar chart, bucketing over the
  `x` date column at `:day`/`:week`/`:month`. Column names are validated against
  the policy's date columns — never raw SQL.

It's a plain view: add headings, your own partials, anything between tiles. Once
the file exists a Dashboard link appears at the top of the sidebar.

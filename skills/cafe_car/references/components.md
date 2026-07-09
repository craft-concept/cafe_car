# Components, CSS, theming

Source: `lib/cafe_car/component.rb`, declarations in `app/ui/cafe_car/ui/*.rb`,
styles in `app/assets/stylesheets/` (all in the gem). This is CafeCar's own
component system — not ViewComponent or Phlex. Any capitalized call in a view is a
component.

## Using components

```haml
= Card title: object.title, image: object.logo, actions: object.controls do |card|
  = card.Section object.show(:price)
  = card.Foot do
    = Button :primary, href: href_for(record) do
      = t(:show)
```

- **Flags** are bare symbols: `Button :primary`, `Button :danger`, `Card :slim`,
  `Page :slim, :center`. They become CSS modifier classes (`Button-primary`).
- **Options** are keywords the component declares (`title:`, `image:`, `actions:`,
  `href:`, `tip:`, `tag:`, `data:`). Anything with `href:` renders as a link and
  gets `current`/`ancestor` classes automatically.
- **Children** are capitalized methods on the block arg: `card.Section`,
  `card.Foot`, `page.Body`, `page.Aside`. Undeclared children work too — they
  become nested class names (`a.Title` inside `Article` → `Article_Title`).
- A component that captures blank content renders nothing — no empty wrappers.

Shipped components include `Page`, `Card`, `Grid`, `Row`, `Group`, `Button`,
`Field`, `Table`, `Alert`, `Menu`, `Navigation`, `Modal`, `Icon`, `Controls`.
Declarations live in the gem's `app/ui/cafe_car/ui/` (e.g. `Card` declares its
flags, options, and named children there).

## Custom components — drop a partial

No registration. Calling `ui.Badge` (or `= Badge` in a view) looks for a partial at
`ui/badge`; give it one:

```haml
-# app/views/cafe_car/ui/_badge.html.haml
%span{ class: badge.class_name }= yield
```

Locals: the component instance under its name (`badge`), plus `options` and
`flags`. The same mechanism overrides the markup of a *shipped* component — a host
`app/views/cafe_car/ui/_card.html.haml` replaces Card's markup app-wide while
keeping its Ruby API.

For behavior-bearing components, declare a class the way the gem does:

```ruby
# app/ui/cafe_car/ui/badge.rb (host)
module CafeCar
  module UI
    component :Badge do
      flag :success
    end
  end
end
```

## CSS — no styles outside components

Owner rule: global CSS is banned; it breaks components reused in unexpected places.
Every component has a scoped stylesheet (gem: `app/assets/stylesheets/ui/Card.css`
etc.) selecting its own class (`.Card`, `.Button-danger`). Style a new component
with its own file selecting its own class names; never restyle tags or other
components globally. The gem's `cafe_car.css` organizes everything in cascade
layers (`vendor, default, theme, component, modifier, layout, utility`).

## Theming

Three bundled themes — sets of CSS custom properties with dark-mode variants:

```ruby
# config/initializers/cafe_car.rb
CafeCar.theme = :cool    # :warm (default), :cool, :cool2
```

The theme is injected as a `<link>` in `<head>` after `application.css`. All tokens
are defined on `:root` in the gem's `themes/defaults.css`: `--accent`, `--primary`,
`--danger`, `--card`, `--button`, `--link`, `--font-family`, `--gap`, `--radius`,
`--page-width`, and friends.

**Caveat:** `CafeCar.theme=` only accepts the bundled names (raises otherwise) —
you cannot register a new named theme. For a custom look, pick the closest bundled
theme and override its `:root` tokens with CSS loaded *after* the theme link —
either override the `_head` partial to append your stylesheet after
`theme_stylesheet_tag`, or use a higher-specificity selector (e.g. `:root:root`)
in your `application.css`:

```css
:root:root { --accent: #7c3aed; --radius: 6px; }
```

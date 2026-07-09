# Presenters — how values render

Source: `app/presenters/cafe_car/presenter.rb` in the gem, plus per-type presenters
alongside it (`CurrencyPresenter`, `DatePresenter`, `RecordPresenter`,
`ActiveRecord::RelationPresenter`, `ActiveStorage::AttachmentPresenter`, …).

`present(value)` (aliased `p` in views) wraps anything in a presenter and returns
an html-safe object. Records render as a linked preview (logo + title); dates,
currency, rich text, attachments, and collections each render through their type's
presenter.

## How a presenter is chosen

The value's ancestor chain is walked and the first `<Ancestor>Presenter` constant
found wins — a host `InvoicePresenter` beats the gem's `RecordPresenter` by
existing; nothing is registered. Force a type with `as:`:

```ruby
present(@invoice)                    # InvoicePresenter, else RecordPresenter
present(record.total, as: :currency) # CurrencyPresenter
```

Note: constants the gem defines under `CafeCar::` (e.g. `CafeCar::StringPresenter`)
resolve engine-first — a same-named top-level constant does *not* shadow them.
Override per model (`ProductPresenter`) or per ancestor the gem doesn't claim.

## Writing one

```ruby
# app/presenters/invoice_presenter.rb
class InvoicePresenter < CafeCar::Presenter
  show :total, as: :currency          # render this attribute through a type
  show :number, -> { "#%03d" % _1 }   # or through a lambda

  def title = show(:number)           # what links/cards/breadcrumbs call this record
end
```

`show` class macros set per-attribute rendering defaults used everywhere the
attribute appears — tables, show pages, cards.

## The instance API (used inside overridden views)

In view code, `present(@article)` (or the `object` local in `_grid_item`) gives:

```ruby
p = present(@article)
p.title                    # policy.title_attribute, rendered
p.logo(size: :icon)        # policy.logo_attribute as an image
p.show(:author)            # one attribute's value, presented
p.attribute(:author)       # labeled Field (label + value)
p.attributes(:a, :b)       # several labeled fields; no args = all displayable
p.remaining_attributes     # displayable minus already-shown
p.associations             # labeled fields for displayable associations
p.timestamps               # created_at/updated_at etc.
p.controls                 # the show/edit/delete control links
p.href                     # canonical path, nil if not routable
p.object                   # the underlying record (for url helpers etc.)
```

## Linking to related objects

`show`/`preview` of an associated record is already a link to it. For explicit
links use the helpers:

```ruby
href_for(record)          # path to the record in the current namespace
link(record).show         # LinkBuilder: policy-aware link (disabled when denied)
link(record).edit
link(record).destroy      # turbo DELETE with locale-driven confirm
link(model).index
link(model.new).new
```

`link(...)` renders disabled-with-tooltip when the policy denies the action —
prefer it over hand-written `link_to` so authorization stays visible in the UI.

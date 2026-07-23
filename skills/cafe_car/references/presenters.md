# Presenters — how values render

Source: `app/presenters/cafe_car/presenter.rb` in the gem, plus per-type presenters
alongside it (`CurrencyPresenter`, `DatePresenter`, `RecordPresenter`,
`ActiveRecord::RelationPresenter`, `ActiveStorage::AttachmentPresenter`, …).

`present(value)` (aliased `p` in CafeCar-rendered views — the alias is
admin-only, in `CafeCar::Helpers`) wraps anything in a presenter and returns
an html-safe object. Records render as a linked preview (logo + title); dates,
currency, rich text, attachments, and collections each render through their type's
presenter.

`present` works in any view — customer-facing pages included, not just
CafeCar-rendered ones. It reaches every view through the installer's
`include CafeCar::Controller` in `ApplicationController`; a host that skips that
include can expose formatting alone with `helper CafeCar::Formatting` (the scalar
`as:` path renders through Rails' own number/date helpers — no CafeCar CSS or
partials).

## How a presenter is chosen

The value's ancestor chain is walked and the first `<Ancestor>Presenter` constant
that inherits `CafeCar::Presenter` wins — a host `InvoicePresenter` beats the
gem's `RecordPresenter` by existing; nothing is registered. Force a type with
`as:`:

```ruby
present(@invoice)                    # InvoicePresenter, else RecordPresenter
present(record.total, as: :currency) # CurrencyPresenter
```

Status-ish attributes are the one convention on top: an ActiveRecord enum, or a
string column named `status`/`state`, renders through `BadgePresenter` as a
colored `Badge` pill wherever the attribute appears — tables, show pages, cards.
`as: :badge` forces it for anything else; per-value styles live in the locale
under `badge.styles` (unlisted values render the neutral badge).

The contract: a host presenter **must inherit `CafeCar::Presenter`** to hook in.
A same-named class that doesn't (an unrelated `ArticlePresenter` serving some
other purpose) is skipped with a `Rails.logger.warn` breadcrumb and lookup falls
through to the shipped defaults. For gem-shipped names (e.g. `StringPresenter`)
the `CafeCar::` constant resolves engine-first, so a top-level presenter of the
same name doesn't shadow it — override per model (`ProductPresenter`) or per
ancestor the gem doesn't claim.

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

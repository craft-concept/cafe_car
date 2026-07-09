# Turbo Streams and live sync

Source: `app/views/cafe_car/application/*.turbo_stream.haml` and
`app/views/application/_head.html.haml` (in the gem).

This is a big reason not to hand-roll admin pages: the defaults carry Turbo 8
morph behavior you'd otherwise rebuild.

## What ships by default

- Every CafeCar page sets `turbo-refresh-method: morph` and
  `turbo-refresh-scroll: preserve` (the `_head` partial), so refreshes patch the
  DOM in place — scroll position, open popovers, and form state survive.
- Create/update/destroy respond to `turbo_stream` with a page refresh
  (`turbo_stream.refresh`), which morphs. Update also removes the record's modal
  if it was edited in one.
- Every show page subscribes to its record: `turbo_stream_from(object)` is in the
  default show template.

## Cross-client live sync is a one-line host opt-in

The subscription is only useful if the model broadcasts. Add Rails'
`broadcasts_refreshes` to the model:

```ruby
class Invoice < ApplicationRecord
  broadcasts_refreshes
end
```

Now any save/destroy — from another browser, a job, the console — morph-refreshes
every open show page for that record. Requires a working ActionCable/Solid Cable
setup in the host, as with any Turbo broadcast.

## Customizing

Override the turbo_stream response per resource like any view
([views.md](views.md)):

```haml
-# app/views/admin/products/update.turbo_stream.haml
= turbo_stream.refresh request_id: nil
= turbo_stream.append "audit_log", partial: "audit_entry", locals: { product: @product }
```

Keep the `refresh` line unless you're deliberately replacing morphing with targeted
streams.

## Don't break it

When writing custom views for a CafeCar resource, keep `turbo_stream_from(object)`
on detail pages and don't strip the `_head` meta tags — hand-rolled pages that drop
these are how admins lose live updates.

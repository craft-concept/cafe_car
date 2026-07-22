# Forms

Source: `lib/cafe_car/form_builder.rb`, `lib/cafe_car/field_builder.rb`,
`lib/cafe_car/field_info.rb`. `CafeCar::Controller` sets `CafeCar::FormBuilder` as
the default form builder — and the installer includes that concern in
`ApplicationController` — so plain `form_for`/`form_with` gets all of this on every
page, customer-facing forms included, with no `cafe_car` macro involved.

The default `_form` partial renders every field the policy permits — most form
changes are `permitted_attributes` changes (see [policies.md](policies.md)), not
view changes.

## Builder methods

```haml
= form_for object, url: href_for(object) do |f|
  = f.field :name                 -# label + input + hint + error, wrapped in a Field
  = f.field :price
  = f.association :category      -# searchable select (see below)
  = f.remaining_fields           -# every editable attribute not yet rendered
  = f.submit
```

- `f.field(method)` — the full labeled field. This is what the default form loops.
- `f.input(method, as: nil, **opts)` — just the input; `as:` forces a helper
  (`as: :hidden_field`, `as: :text_area`, …).
- `f.association(method)` — a select for a `belongs_to`/`has_many`.
- `f.remaining_fields` — `policy.attributes.editable` minus fields already built;
  keeps custom forms policy-driven instead of hand-listing everything.
- `f.hidden(:a, :b)`, `f.label`, `f.hint`, `f.error` as expected. Labels append `*`
  for presence-validated fields; label/hint/placeholder text comes from the locale
  (see [locales.md](locales.md)).

## Type inference

`FieldInfo#input` picks the input from the schema — string/decimal → text field,
text/json → textarea, integer → number, boolean → checkbox, date/datetime → typed
pickers, `has_secure_password` digests → password fields, ActiveStorage attachments
→ file field (`multiple` for `has_many_attached`), ActionText → rich text area,
`belongs_to`/`has_many` → association select, `accepts_nested_attributes_for` →
nested sub-forms.

## Association selects

`f.association :client` renders a select capped at `CafeCar.max_collection_options`
(default 100) options, enhanced with Tom Select typeahead that queries the model's
policy-scoped `GET /clients/options?q=…` feed — records past the cap stay reachable,
hidden rows never leak, and without JS it degrades to a plain select. Option labels
come from each record's presented `title`.

## Nested records

`accepts_nested_attributes_for :line_items, allow_destroy: true` plus the permit:

```ruby
def permitted_attributes
  [ :number, :issued_on,
    line_items_attributes: [ :id, :_destroy, *policy(LineItem).permitted_attributes ] ]
end
```

The default form then renders add/remove-able line-item rows with no view code.
`f.fields_for :line_items` (no block) renders each sub-record's
`remaining_fields`.

## Overriding how a field type renders

`f.field` renders through a partial named after the field's type —
`_<type>_field.html.haml`, falling back to the generic `_field.html.haml`:

```haml
-# app/views/application/_string_field.html.haml  (app-wide for all string fields)
-# app/views/admin/products/_string_field.html.haml  (this resource only)
= field.wrapper do
  = field.label
  = field.input data: { controller: "autosize" }
  = field.error
```

The `field` local is a `FieldBuilder`: `field.label` / `field.input` / `field.hint`
/ `field.error` / `field.info` (the `FieldInfo`). Type names match the inference
above: `string`, `text`, `integer`, `boolean`, `date`, `datetime`, `password`,
`attachment`, `nested`, `belongs_to`, `has_many`, `json`.

(`lib/cafe_car/inputs/` exists in the gem but is dormant — the live path is
FieldBuilder + FieldInfo + these partials.)

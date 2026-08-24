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

A field type has two override points, then: the `_<type>_field` partial above
(its layout) and its **input component** (the input element itself). `field.input`
— like `f.input` directly — renders through a small per-type component under
`lib/cafe_car/inputs/`: `FieldInfo#input` resolves the field's type to a key, and
`Inputs::BaseInput.classes` maps that key to the component that emits the bound
input (`StringInput`, `NumberInput`, `AssociationInput`, `NestedInput`, …). This
is the live default input path — not the partials alone. An explicit `as:` naming
a helper the family doesn't own (e.g. `as: :hidden_field`) falls through to that
plain form helper instead, preserving `#input`'s "render via any form helper"
contract.

## Standalone vs admin-coupled

The builder is on every `form_for`/`form_with`, customer-facing pages included.
Most methods are drop-in anywhere; a few pull in the Pundit policy or the admin
view/CSS layer for their *full* render:

| Method | Drop-in | Full render also needs |
|---|---|---|
| `label`, `hint`, `error`, `error_text` | yes | nothing — plain `<label>`/`<small>`/`<span>`, copy from the locale (`label` falls back to the humanized name) |
| `input` (scalar types) | yes | a native Rails form helper; `ui/Input.css` styles it and degrades to an unstyled input without |
| `hidden` | yes | nothing |
| `association`, and `input` for a `belongs_to`/`has_many` | no | the associated model's Pundit policy scope (its options obey it) |
| `field` | no | the `_<type>_field`/`_field` partials and the `Field` component (`.Field` layout CSS) |
| `remaining_fields`, `remaining_attributes` | no | the record's Pundit policy (`attributes.editable`) |
| `submit` | no | the `ui` button class (styling only) |

So a customer-facing form that just renders and validates a couple of fields —
no admin partials, `.Field` CSS, or policy — is the standalone surface:

```haml
= form_with model: @review do |f|
  = f.label :rating
  = f.input :rating
  = f.error :rating          -# validation errors for one field, a plain <span>
  = f.submit
```

For read-only values on that page, `present(val, as: :currency)` is
`CafeCar::Presenter.present(view, val, as:)` under the hood (see
[presenters.md](presenters.md)) — html-safe, type-picked formatting with no admin
partials or CSS. A host that skips the `CafeCar::Controller` include can still
expose that scalar `as:` path alone with `helper CafeCar::Formatting` — Rails' own
number/date helpers, nothing else.

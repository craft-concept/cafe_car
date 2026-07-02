---
id: major-feature-gaps-post-audit
title: Major feature gaps vs. peer admin gems (post-audit tracking)
priority: P2
status: open
domain: Product
created: 2026-07-02
---

**Source:** completeness audit 2026-07-02 (graybeard). The four P1 blockers are filed separately
(nested forms, references generator, filter syntax, N+1). This tracks the majors/minors — split each
into its own task when picked up. Sequence AFTER the blockers (fix what's advertised-but-broken
before adding advertised-but-missing surface).

**Majors:**
- **#5 Unbounded association `<select>`** — `lib/cafe_car/field_info.rb#collection` is
  `reflection.klass.all`, no cap/search/pagination. Backs both edit-form `collection_select` AND the
  filter sidebar. A `belongs_to :client` with 10k rows renders a 10k-`<option>` select on every form
  and index load. Fix: configurable cap + warning, ideally a searchable/remote select (Tom Select).
- **#6 `has_many_attached` advertised but unimplemented** — README:484 claims it; only
  `has_one_attached` works. `lib/cafe_car/filter/form_builder.rb:16-17` has a literal
  `# TODO: handle multiple/index`. Fix: wire `multiple:` to a real `<input multiple>` + array params,
  OR drop the claim from the README until built.
- **#7 No bulk actions** — table-stakes in ActiveAdmin/Avo/Administrate (bulk delete, status change,
  export-selected). Needs multi-row selection UI + per-row batch authorization + action registration.

**Minors / positioning:**
- **#8 No dashboard/homepage capability** — positioning decision (stay a CRUD generator vs. full
  admin framework). Defer/decide.
- **#9 Theming hooks absent** — `cool.css`/`cool2.css` exist under
  `app/assets/stylesheets/cafe_car/themes/` but are never imported; no config API to select a theme.
- **#11 Pagination `per` has no cap** — `?per=1000000` → HTTP 200, loads whole table. The CSV path
  is correctly capped (`CafeCar.csv_export_row_limit`); mirror it. Perf/DoS footgun. (S — do soon.)
- **#10 Undocumented unauthenticated `/components` route** — `examples_controller.rb` skips
  policy/authorization on `:index`, mounted into the host admin namespace, not in the README.
  Dev-gate it, make it opt-in, or document it.

**Nits (fix while touching the file):**
- **#12** `lib/cafe_car/attributes.rb#editable` — `@permitted.map()` (no block) returns an Enumerator,
  not an Array. Dead code today; landmine when wired up.
- **#13** `lib/cafe_car/auto_resolver.rb` — dead `const_missing` auto-generation; its auto-policy
  `admin?` is `Rails.env.development?`. Delete or document before someone activates it.

**Meta-finding (the most important one — own task-worthy):** the green suite gives false confidence
because tests assert *request shape* (page renders, markup present) not *effect* (data changed, query
count bounded). Every blocker fix must land with an EFFECT-level test. A single integration guard —
generate a resource, submit every field type through its real form, assert persistence + bounded
queries — would catch this whole bug class before it ships. Consider adding it as a standing harness.

---
id: keyword-search
title: Turnkey keyword search across resource indexes
priority: P2
status: open
domain: Eng
created: 2026-06-27
---

Make keyword search work out-of-the-box on every auto-generated index. The plumbing is
half-wired today: `QueryBuilder#search!` (`lib/cafe_car/query_builder.rb:156`) delegates to a
host-defined `search`/`search!` scope (`update! { _1.search(term) }`), so it only works if the
host model hand-writes `scope :search` (only `article`/`user` do in the dummy app) — and there
is **no search box in any view**. This is the ⚠️ gap on [[dogfood-crayonbloom]]'s readiness map;
every comparable admin gem ships turnkey search. Companion to [[csv-export]].

## Scope

1. **Default search scope.** When a model does NOT define its own `search` scope, CafeCar
   should provide a default that matches the term against the model's **string/text columns**,
   case-insensitively and DB-portably (use Arel `#matches`, which emits `ILIKE` on Postgres /
   `LIKE` on SQLite/MySQL — do not hand-write `ILIKE`). A host-defined `scope :search` must
   still win (backward compatible — `article`/`user` keep their custom scopes). Natural home is
   the `CafeCar::Queryable` model concern (`lib/cafe_car/queryable.rb`).
2. **Policy-respecting columns.** The default only searches columns the policy exposes —
   intersect string/text columns with the policy's displayable attributes (same guarantee CSV
   export and the JSON renderer give; see `lib/cafe_car/policy.rb`). Never search hidden columns.
3. **Search box in the index UI.** Add a search input to the index view
   (`app/views/application/_index.html.haml` / a toolbar partial) that drives the keyword query
   and preserves existing dot-filters + sort. **Nail down the param plumbing:** the term must
   reach `filtered → scope.query(parsed_params[""])` as a bare String so `query!` routes it to
   `search!` (see `lib/cafe_car/controller/filtering.rb` + `lib/cafe_car/param_parser.rb`).
   Determine the exact param shape empirically (write a quick test / experiment against
   `ParamParser`). If the bare-`""` path proves too obscure to drive from a form cleanly,
   introducing a clean dedicated search param that funnels into the same `search!` is acceptable
   — as long as it integrates with the existing query DSL and doesn't regress dot-filters.
4. Show the active search term in the box when present; the existing "View all" reset link
   should clear it too.

## Acceptance

- A model with NO custom `search` scope (e.g. dummy `Client` or `Invoice`) returns the matching
  subset for a keyword query across its string/text columns; case-insensitive.
- Host-defined `scope :search` (dummy `Article`/`User`) still takes precedence — unchanged.
- Hidden/non-displayable columns are never searched (policy-respected).
- The index search box submits the query, preserves dot-filters + sort, and round-trips the term.
- New tests cover: default-search subset, custom-scope precedence, policy exclusion, and the
  controller/param path end-to-end.
- `CHANGELOG.md` `[Unreleased] → Added` notes it; `rake` green; committed + pushed.

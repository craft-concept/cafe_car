---
id: fix-index-n-plus-one-eager-loading
title: N+1 queries on every index that shows an association (no eager loading anywhere)
priority: P1
status: open
domain: Eng
created: 2026-07-02
---

**Source:** completeness audit 2026-07-02 (graybeard), blocker #3. Empirically measured: 5 rows w/
distinct associations = 17 queries, 15 rows = 37 queries — clean `7 + 2N` fit. Works fine in a 5-row
demo (how a prospect first tries it), degrades linearly on every real table.

**Bug:** Any index rendering a `belongs_to`/`has_many` column (the default —
`displayable_attributes` auto-includes associations) issues one query per row per association. No
`.includes`/`.preload` anywhere.

**Root cause:** `lib/cafe_car/controller.rb#scope` pipeline is
`model.all.then { policy_scope }.then { sorted }.then { filtered }.then { paginated }` — no eager
loading. `app/presenters/cafe_car/presenter.rb#show` calls `object.try(method)` directly per row.
Secondary: `lib/cafe_car/table/row_builder.rb#to_html` opens a `turbo_stream_from(@object)`
subscription per row.

**Fix:** Add `.includes` to the scope pipeline based on the association set in
`policy.displayable_attributes`. Watch polymorphic associations (can't be naively `.includes`d).

**Acceptance:**
- A **query-count regression test** — the repo has NONE today, so even a correct fix has nothing
  stopping it from silently regressing. ⚠️ Trap for the implementer: FactoryBot `.sample`-based
  association helpers + AR's per-request query cache make a *broken* fix look correct (flat query
  count) unless the test forces DISTINCT associations per row. The audit hit this — control for it.
- `bundle exec rake` green. `CHANGELOG.md` `[Unreleased]` entry.

Related scale footgun: [[major-feature-gaps-post-audit]] #5 (unbounded association `<select>`).

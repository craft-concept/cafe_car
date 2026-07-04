# Ideas — CafeCar

The venture's imagination stream: one line per idea, newest first. **Killed ideas stay listed** so
they aren't re-proposed.

**Status legend:** `proposed` (filed to the owner via `/propose`, awaiting a call) · `running`
(cheap idea in flight) · `kept` (tried, worked, kept) · `killed` (tried or proposed, then dropped —
say why).

How this works: see `AGENTS.md` → "Ideation". Cheap, reversible ideas you run yourself (log the
outcome here); consequential ones you `/propose` to the owner — they surface in holdco's
`bin/holdco asks --notify` digest under 💡 Proposals.

| Date | Idea | Status | Outcome / why |
|------|------|--------|---------------|
| 2026-07-03 | **Dashboards + bulk actions via views/partials** (drop the config DSLs) — a design proposal grounding both features in CafeCar's existing view-override convention: a dashboard is one host-authored `cafe_car/dashboard/show` template composing `metric`/`chart` helpers; a bulk action decomposes into a `_bulk_actions` partial button + a model bang method + a policy predicate. Reworks the mechanism, keeps the features. | kept | Owner approved 7/3 19:32 ("very close!") with corrections: policy is the source of truth (`permitted_bulk_actions`/`permitted_metrics`, partials loop the list by default), button styles + all copy in locales. Both reworks SHIPPED — commit 12416c0, rake green, DSLs deleted. |

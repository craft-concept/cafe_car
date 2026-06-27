---
id: dogfood-crayonbloom
title: Milestone — CafeCar usable for CrayonBloom back-office
priority: P1
status: open
domain: Product
created: 2026-06-26
blocked_on: user
---

Owner milestone: make CafeCar good enough to power CrayonBloom's back-office (dogfooding).
Dogfooding is the fastest way to surface real gaps and earn credibility ("we run our own
business on it").

- Enumerate what CrayonBloom's back-office needs (resources, auth, roles, filtering,
  exports) and map to CafeCar capabilities; the deltas become Eng tasks.
- Strongest forcing function for [[fix-halfbaked-features]] and v1 scope.
- Owner input likely needed on CrayonBloom requirements — capture open questions in
  QUESTIONS.md.

## Back-office readiness map — 2026-06-26 (generic; awaiting CrayonBloom specifics)

What a typical business back-office needs vs. what CafeCar demonstrably does today
(evidence: `V1_SCOPE.md` + the live demo's clients/invoices/line-items/articles admin).
The ❌/⚠️ rows are the deltas that become Eng tasks **if CrayonBloom needs them** —
held until the owner confirms scope (see QUESTIONS.md).

| Back-office need | CafeCar today | Status |
|---|---|---|
| Resource CRUD (index/show/new/edit) | `cafe_car` one-liner, all 7 actions | ✅ proven (demo) |
| Authorization + roles | Pundit policies, attribute-level perms, scopes | ✅ (the role model itself is host-supplied) |
| Auth / login | opt-in sessions (finished; CRUD-only hosts 403 not 500) | ✅ opt-in |
| Filtering | query DSL — ranges, operators, association counts | ✅ |
| Full-text / keyword search | — (only attribute filters) | ⚠️ gap |
| Sorting + pagination | Kaminari-backed | ✅ |
| Associations incl. nested forms | belongs_to selects + has_many nested attrs | ✅ (closed issue #10) |
| File / image uploads | Active Storage (avatars in demo) | ✅ (host-wired) |
| Rich text | Action Text | ✅ |
| Audit log / versioning | PaperTrail CRUD'd as a resource | ✅ (host-supplied) |
| CSV / data export | JSON responses only | ❌ gap |
| Bulk actions (multi-select ops) | — | ❌ gap |
| Dashboard / metrics / charts | — | ❌ out of current scope |

**Gap-derived candidate Eng tasks** (file only if CrayonBloom needs them): CSV/data export,
bulk actions, keyword search, dashboard widgets. None blocks generic CRUD-admin dogfooding —
the ✅ rows already cover a clients/invoices-style back-office (the demo proves it).

**Status:** the generic enumeration is done; the milestone is now blocked on CrayonBloom's
concrete requirements (resources, roles, must-have capabilities, and whether there's a repo
to read). Questions filed in QUESTIONS.md → `blocked_on: user`.

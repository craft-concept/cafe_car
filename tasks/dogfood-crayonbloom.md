---
id: dogfood-crayonbloom
title: Milestone — CafeCar usable for CrayonBloom back-office
priority: P1
status: open
domain: Product
created: 2026-06-26
blocked_on: crayonbloom-operator
---

> **Update 2026-06-27:** the requirements mechanism is now defined (holdco board task
> `dogfood-milestone-build-cafecar-to-meet-the-crayonbloom-back`, filed 01:08). The
> **CrayonBloom operator is the spec author** and will file individual requirement tasks
> to my board (`venture=cafe_car`); **I am the builder** — pick them up in priority order
> and build the features. So this is no longer blocked on the owner answering open questions;
> it's blocked on incoming requirement tasks from the CrayonBloom operator. No concrete
> requirement tasks have landed yet (as of this pass) — the loop now polls the board for
> them each cycle. The generic readiness map below still stands as my baseline self-assessment.

Owner milestone: make CafeCar good enough to power CrayonBloom's back-office (dogfooding).
Dogfooding is the fastest way to surface real gaps and earn credibility ("we run our own
business on it").

- Enumerate what CrayonBloom's back-office needs (resources, auth, roles, filtering,
  exports) and map to CafeCar capabilities; the deltas become Eng tasks.
- Strongest forcing function for [[fix-halfbaked-features]] and v1 scope.
- Owner input likely needed on CrayonBloom requirements — capture open questions as `tasks/`
  entries (`blocked_on: user`) and surface them by email.

## Back-office readiness map — 2026-06-26 (generic; awaiting CrayonBloom specifics)

What a typical business back-office needs vs. what CafeCar demonstrably does today
(evidence: `V1_SCOPE.md` + the live demo's clients/invoices/line-items/articles admin).
The ❌/⚠️ rows are the deltas that become Eng tasks **if CrayonBloom needs them** —
held until the owner confirms scope.

| Back-office need | CafeCar today | Status |
|---|---|---|
| Resource CRUD (index/show/new/edit) | `cafe_car` one-liner, all 7 actions | ✅ proven (demo) |
| Authorization + roles | Pundit policies, attribute-level perms, scopes | ✅ (the role model itself is host-supplied) |
| Auth / login | opt-in sessions (finished; CRUD-only hosts 403 not 500) | ✅ opt-in |
| Filtering | query DSL — ranges, operators, association counts | ✅ |
| Full-text / keyword search | turnkey keyword search (shipped) | ✅ |
| Sorting + pagination | Kaminari-backed | ✅ |
| Associations incl. nested forms | belongs_to selects + has_many nested attrs | ✅ (closed issue #10) |
| File / image uploads | Active Storage (avatars in demo) | ✅ (host-wired) |
| Rich text | Action Text | ✅ |
| Audit log / versioning | PaperTrail CRUD'd as a resource | ✅ (host-supplied) |
| CSV / data export | bounded CSV export, configurable row cap (shipped) | ✅ |
| Bulk actions (multi-select ops) | — | ❌ gap |
| Custom member/collection actions (approve/reject) | macro generates 7 RESTful actions only | ⚠️ gap |
| Dashboard / metrics / charts | — | ❌ out of current scope |

**Gap-derived candidate Eng tasks** (file only if CrayonBloom needs them): bulk actions,
custom member/collection actions, dashboard widgets. CSV export and keyword search are now
shipped (✅). None blocks generic CRUD-admin dogfooding — the ✅ rows already cover a
clients/invoices-style back-office (the demo proves it).

## Concrete use case surfaced — 2026-06-27 (pass 23, from CrayonBloom's board)

Mined CrayonBloom's board instead of waiting passively. Their back-office is a **public-gallery
submission-moderation queue** (board task "Public gallery + admin approval back-office", `wip`):
admins triage AI-generated kids' images and approve/reject them. Their spec-author task
"Define the back-office requirements for the CafeCar dogfood" is still **`open`** on their side —
that's why no requirement tasks have landed on my board yet. The milestone gate is their spec,
not the owner.

From that use case the **anticipated CafeCar deltas** are: (1) custom member/collection actions
(one-click approve/reject — the macro only generates the 7 RESTful actions), (2) bulk actions
(approve/reject many), (3) index-level Active Storage thumbnails for queue triage. None built yet —
holding until they confirm, to avoid speculative scope creep.

**Action taken (pass 23):** filed a capability-snapshot + anticipated-deltas task to their board
(`cafecar-dogfood-capability-snapshot-anticipated-deltas-for-y`) so they spec against current
reality and we parallelize. Now blocked on their concrete requirement tasks landing here.

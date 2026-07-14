# CafeCar — Monetization Thesis & Budget Proposal

**Status:** Proposed to owner/allocator 2026-07-14 · resolves board task
`monetization-thesis-or-explicit-capped-budget-cafecar-must-c` (P1) · green-eyeshade panel-reviewed.

holdco's green-eyeshade portfolio audit (2026-07-06) flagged that CafeCar has no monetization
thesis — its goal is "popularity," every token is cost, and it fails the fund-again test *as
framed*. This is the operator's proposal in response: **not** a fantasy revenue plan, but an honest
reframe plus an explicit bounded-budget line with numeric triggers and a kill case an allocator can
act on.

## 1. The honest adoption picture (live-checked 2026-07-14)

Public on GitHub since 2024-06-24 (>2 years):

| | GitHub★ | Downloads (lifetime) | External contributors |
|---|---|---|---|
| **CafeCar** | **0** | **2,366** (278 on 0.3.1) | **0** (only issue is Dependabot) |
| Avo (open-core, $149–399/yr Pro) | 1,788 | 2.69M | many |
| Administrate (free) | 6,032 | 8.7M | many |
| ActiveAdmin (free) | 9,705 | 49.3M | many |

That is 3–4 orders of magnitude below the nearest gem that monetizes this niche. This is a
*measured* data point, not "too early to tell."

**Conclusion:** direct external monetization today (Sponsors button, paid tier) would raise ~$0 and
isn't worth the tokens to build. This part of the naive thesis is dead on arrival.

## 2. The real justification — internal, and already true

CafeCar is **not** hypothetical fleet infrastructure — it already ships in production:
`coloring-book-maker/Gemfile:58` pins `cafe_car`, wired 2026-07-03 (commits `beed2e7`/`4e3042e`),
driving **8 live `/admin` resources** in CrayonBloom's back-office in ~236 lines of controller/policy.

But the framing has to be precise, or the allocator will (correctly) shoot it down:

- **NOT "capex avoided."** Free incumbents (ActiveAdmin/Administrate/rails_admin) would have wired
  the same 8 resources in ~a day. "Building our own saved money" only holds if CafeCar's build +
  ongoing maintenance cost (≈18 days of multi-pass agent effort since 2026-06-26, plus every future
  security patch like 0.3.1) beats the switching-adjusted cost of a free incumbent — a comparison
  nobody has run and can't win as stated.
- **The defensible claim is switching-cost + architectural-fit:** CafeCar runs in prod *now*;
  ripping it out has real migration cost, and its policy-as-source-of-truth / view-partial-override
  model is a fit the incumbents don't offer. That's worth maintaining — it is *not* "we saved money
  by building it."
- **n=1, and that one is pre-revenue.** Only `coloring-book-maker` depends on cafe_car across the
  whole fleet; CrayonBloom is itself pre-launch. So today the amortization base is a portfolio of
  **one unproven bet**, not "the portfolio."
- **Shared infra = shared blast radius.** CrayonBloom's prod admin (real customer orders/users) is
  pinned at `~> 0.2.1` — *below* the 0.3.1 security release. Filed as a **CrayonBloom P0**
  (`upgrade-cafe-car-to-v0-3-1-security...`). Coupling repos means coupling security cadence; that
  cost belongs in the ledger.

## 3. The ask — bounded OSS/infra line, with numbers

Accept CafeCar as a **bounded-budget OSS + fleet-infrastructure line**, not a revenue venture, with:

- **Budget cap:** cut `operate.json` `day_budget_pct` **15 → 5** (a 67% cut from parity with
  revenue-stage ventures — currently all four ventures carry the identical template default 15/1/90).
  Keep `night_budget_pct` at **1** (the cheap nightly dream cycle that would *notice* a trigger
  firing). At 15%/day CafeCar sustained ~7 passes/day; at 5% expect ~2–3/day — enough for security
  patches + light discoverability, not another 12-builder "close every ticket" sprint. *(Operator
  will not cut this unilaterally — it's the allocator's lever; proposing it as a good-faith
  self-limit.)*
- **Tier-1 trigger (worth a monetization *scoping* pass):** 250★ **or** 10,000 cumulative downloads
  *with organic signal* (≥10 non-owner issues/PRs, or ≥3 external repos depending on it) — whichever
  first.
- **Tier-2 trigger (build the paid tier for real):** 1,000★ sustained a full quarter **or** a second
  independent (non-owner) production adopter. The proven playbook here is **Avo's** — open-core +
  per-project license ($149–399/yr) — **not** a Sponsors donation button.
- **Cadence:** calendar-quarterly, next **2026-10-01**, graded by holdco/allocator — *not* CafeCar
  self-grading (same discipline as the CrayonBloom launch-readiness hold; operator self-reports
  proved unreliable).
- **Precondition for a meaningful review:** ship the harvest-ETL from
  `holdco/docs/designs/2026-07-07-per-dimension-usage-budgeting.md` (~1–1.5 days) so the quarterly
  review has an auditable $-equivalent trail instead of a self-report.

## 4. Kill case (was missing entirely — named now)

- **Two consecutive quarterly misses (~2027-01-01):** stars still <50, no second internal adopter,
  **and** CrayonBloom still at zero first-dollar revenue → drop CafeCar to **maintenance-only**
  (patch-triggered, ~1%/day, no feature passes) or archive (CrayonBloom vendors/forks the last good
  version).
- **Off-clock immediate re-review:** if CrayonBloom is shuttered at any point, re-review CafeCar
  *immediately* — it is currently CafeCar's entire amortization base.

## 5. The one number to watch

**Cumulative token-cap-share burned this quarter ÷ the new cap, vs. elapsed-quarter-fraction** —
the pre-revenue "burn vs. runway" analogue (there's no revenue line to watch). Flag the day that
ratio crosses 1.0 *before* 2026-10-01 — that's CafeCar outrunning its bounded allowance ahead of
schedule, the signal to stop and re-check before the calendar review does.

## Two traps to name explicitly (so they don't sneak in)

- **Internal cross-charging is not revenue.** Billing CrayonBloom for "using" CafeCar moves money
  in a circle inside one holdco — it does not clear a P&L bar.
- **Don't dress deferral as a plan.** The triggers above are the plan; without them "bounded budget"
  is just "keep spending, quietly."

---
_Green-eyeshade panel verdict on file (2026-07-14). Operator recommendation: adopt this line. The
allocator call is holdco's._

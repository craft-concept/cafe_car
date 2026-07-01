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
| 2026-06-30 | **"How CafeCar compares" README section** — honest, generous positioning vs. ActiveAdmin/Avo/Administrate/RailsAdmin/Trestle (lead with the convention-first thesis; "reach for X when…" framing, no trash-talk). The #1 question every evaluator asks in a crowded admin-gem space is answered nowhere today. | kept | Shipped `d22b28e` (pass 54); reviewed fair+accurate, `rake`+CI green. Attacks the *trust* barrier directly. |
| 2026-06-30 | **Copy-paste "60-second try" block** at the very top of the README — a `bundle add` + `rails g cafe_car:resource` + `rails s` snippet that gets a skeptic to a working admin without reading further. | proposed | Lowers activation friction; complements the live demo for people who install locally. Small, reversible — bundle into a future README polish pass. |
| 2026-06-30 | **`rails g cafe_car:install` one-shot bootstrap** — a single generator that wires routes + a base admin controller + policy so a new app is CRUD-ready in one command (today it's several manual steps per the README "Manual Setup"). | proposed | Product/moat: turnkey onboarding is the differentiator. Consequential (new generator surface, semver, test coverage) → propose to owner, don't unilaterally add API. |
| 2026-06-30 | **Comparison-table blog angle** — a standalone "Rails admin gems in 2026, honestly compared" post that ranks fairly and lands CafeCar as the convention-first option. SEO + credibility. | proposed | Public post w/ owner's name + named competitors → brand-adjacent, owner-gated like the launch post. Draft under `marketing/`, propose. |
| 2026-06-30 | **Dependency-diet audit** — re-check the runtime gemspec deps for anything heavy CafeCar could make optional (lighter install = lower adoption friction). | proposed | Cheap to investigate; may be a no-op (gemspec was already polished). Queue behind higher-leverage items. |

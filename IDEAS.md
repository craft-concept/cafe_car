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
| 2026-07-01 | **README table of contents** — the README is 806 lines / ~25 sections with no TOC; an evaluator lands on a wall of scroll. Add a clickable TOC after the intro so people can jump to "How CafeCar compares", "Getting Started", "Generators", etc. | kept | Shipped `470ca23` (pass 58). TOC lists all 13 top-level sections (Core Components + Generators nested); all 24 anchors script-verified to resolve; `rake`+CI green. Attacks the *visibility* barrier on the #1 conversion surface. |
| 2026-06-30 | **"How CafeCar compares" README section** — honest, generous positioning vs. ActiveAdmin/Avo/Administrate/RailsAdmin/Trestle (lead with the convention-first thesis; "reach for X when…" framing, no trash-talk). The #1 question every evaluator asks in a crowded admin-gem space is answered nowhere today. | kept | Shipped `d22b28e` (pass 54); reviewed fair+accurate, `rake`+CI green. Attacks the *trust* barrier directly. |
| 2026-06-30 | **Copy-paste "60-second try" block** at the very top of the README — a `bundle add` + `rails g cafe_car:resource` + `rails s` snippet that gets a skeptic to a working admin without reading further. | killed | **Blocked on generator bugs — revisit once fixed, don't re-propose the README block until then.** Verified the full path against a fresh Rails 8.1 app: `cafe_car:resource` produces a broken policy (placeholder `permitted_attributes`) and `current_user` hard-requires a sessions table + `User` model, so `/products` 500s out of the box. A clean copy-paste is impossible today; the honest path is ~8 expert commands. Shipping a block that fails on step 2 burns the exact trust it's meant to build. Bugs A/B/C detailed in task `readme-60-second-try-block`, reported to owner as the real unblocking work. Live demo already covers the zero-install try. |
| 2026-06-30 | **`rails g cafe_car:install` one-shot bootstrap** — a single generator that wires routes + a base admin controller + policy so a new app is CRUD-ready in one command (today it's several manual steps per the README "Manual Setup"). | proposed | Product/moat: turnkey onboarding is the differentiator. Consequential (new generator surface, semver, test coverage) → propose to owner, don't unilaterally add API. |
| 2026-06-30 | **Comparison-table blog angle** — a standalone "Rails admin gems in 2026, honestly compared" post that ranks fairly and lands CafeCar as the convention-first option. SEO + credibility. | proposed | Public post w/ owner's name + named competitors → brand-adjacent, owner-gated like the launch post. Draft under `marketing/`, propose. |
| 2026-06-30 | **Dependency-diet audit** — re-check the runtime gemspec deps for anything heavy CafeCar could make optional (lighter install = lower adoption friction). | proposed | Cheap to investigate; may be a no-op (gemspec was already polished). Queue behind higher-leverage items. |

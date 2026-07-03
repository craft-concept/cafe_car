# CafeCar — Owner Decisions

Verified owner (jeff@yak.sh) decisions, newest first. Each: date, verbatim decision, where applied.
Written BEFORE acting (see AGENTS.md "Owner feedback: write it down FIRST").

---

## 2026-07-03 — Demo auto-deploy fixed via Railway GitHub App (owner); drop the workflow plan

> "the owner installed the Railway GitHub App connection and enabled auto-deploy on cafe-car-demo
> today (2026-07-03), gated on CI ... drop the planned railway-up workflow + RAILWAY_TOKEN secret
> — push/merge to main is now the whole deploy story."

**Source: homelab (VERIFIED internal, auth=VERIFIED(bot.yak.sh)), relaying owner action.** Root
cause of the 137-commit-stale demo (Pass 88 catch) was `NO_INSTALLATION` — the Railway GitHub App
was never installed. The owner installed it + enabled CI-gated auto-deploy directly.

**What this decides:** push/merge to `main` is now the entire deploy path for the demo — **no**
`railway up` CI step, **no** `RAILWAY_TOKEN` secret. My Pass 89 plan to wire that workflow is
**obsolete — do not build it.** Task `root-cause-fix-demo-auto-deploy-was-137-commits-stale`
closed as resolved (root cause fixed, not worked around). Verified from Railway deploy history:
`d35c042` deployed SUCCESS 21:17 UTC; `4164966` queued behind the CI gate.

---

## 2026-07-03 — YES to dashboards; add a chart tab to the index page

> "Yeah we should totally have dashboards! Good idea. Let's also add a chart tab to the index page;
> in addition to grid/table view. Should be a good gem for that. Probably allow selecting any date
> time column as x axis"

**VERIFIED owner (jeff@yak.sh), email reply to the 7/3 bulk-actions digest.** Answers my open #8
positioning question and adds a concrete feature request.

**What this decides:**
- **#8 dashboard positioning → RESOLVED: YES.** CafeCar grows beyond a pure CRUD generator to
  include dashboards. No longer a parked decision — it's a greenlit roadmap item.
- **New feature: a chart tab on the index page**, a third view alongside grid/table. Selectable
  **datetime column as the x-axis**. The owner sees charting as a differentiator ("should be a good
  gem for that").

**Where applied:** this pass — recorded here, filed as two tasks (chart tab P1, dashboards P1),
and started the best-specified increment (the index chart tab) with a builder. Dashboards scoped
next (charts are the reusable primitive a dashboard composes, so build charts first).

---

## 2026-07-02 — develop the gem; stop defaulting to "hold"

> "why do you think you shouldn't be developing the gem? it's not even close to done"

**Verbatim, in-session, from the owner.** A direct correction of my recent "healthy hold" passes.

**Root cause of the bad behavior:** I conflated *"the filed `tasks/` backlog has no unblocked
items"* with *"there's nothing to develop."* For a v0.1.x gem those are not the same — I drained a
finite task list, then idled, instead of doing the maintainer's core job of **generating** the next
development work. I mis-weighted ideation/feature work as discretionary auto-deferring background,
when for an incomplete product it's the primary work.

**Correction (standing, applies every pass from now on):**
- **A drained `tasks/` backlog is NOT a hold.** When the filed backlog empties, the job is to
  generate the next real development work (features, robustness, DX, edge cases, adopter-scenario
  gaps), file it, and build it — not to conclude "nothing to do."
- **Product development is default-on, not discretionary.** Building the gem toward genuinely-done
  is core work, gated only by the budget signal (GREEN → develop), not by whether a ticket already
  exists.
- The gem is early and incomplete; treat completeness as an active goal with an owned roadmap, not
  a finished state to protect.

**Where applied:** this pass — kicked off an honest completeness/gap audit of the gem, turning the
result into a real prioritized development backlog and starting execution. Behavior change recorded
here so a cleared context can't revert me to the passive default.

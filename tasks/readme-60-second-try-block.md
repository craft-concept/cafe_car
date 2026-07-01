---
id: readme-60-second-try-block
title: Add a copy-paste "60-second try" quickstart at the top of the README
priority: P2
status: done
domain: Eng
created: 2026-07-01
---

**Outcome (2026-07-01): not shipped — verification killed it.** Ran the full
install → generate → serve → visit-admin path against a fresh Rails 8.1 app with
the local gem. A clean copy-paste quickstart is impossible today: the flow is
blocked by four generator/runtime bugs (see below), so any honest block would be
a ~8-command expert workaround that fails on step 2 for a skeptic — worse than no
block, per this task's own accuracy gate. README left unchanged; the true
zero-install "60-second try" (the live demo) already sits at the very top. IDEAS
row flipped to `killed` (blocked on generator bugs — revisit once fixed). Bugs
reported to the owner as the real unblocking follow-up:

- **A — `current_user` ignores the opt-in-sessions gate.** `current_user →
  current_session → build_session` unconditionally does `CafeCar::Session.new`
  (needs the `sessions` table) and `.user` (needs a `User` model). Pundit's
  default `pundit_user` is `current_user`, so *every* authorized action 500s in a
  fresh app until you run `cafe_car:sessions` + migrate **and** define a `User`
  model. Contradicts the README's "plain CRUD works with no login → 403 not 500"
  promise. `authentication.rb` already has a `sessions_available?` gate; it just
  isn't consulted here.
- **B — `cafe_car:resource` drops the field list.** It invokes `cafe_car:policy`
  without forwarding the `name:string price:decimal` args, so the policy falls
  back to the introspection path.
- **C — policy introspection is broken.** `cafe_car:policy` calls
  `CafeCar[:ModelInfo].new(model_class)` positionally, but `ModelInfo#initialize`
  requires the `model:` keyword → `ArgumentError` whenever the model exists. When
  the model *can't* be constantized mid-run it instead writes the literal
  placeholder `permitted_attributes [:create_model_first_to_generate_attributes]`.
- **Net effect:** `rails g cafe_car:resource Product name:string price:decimal`
  always produces a broken policy, so `/products` 500s (`NoMethodError` on the
  placeholder attribute) until the policy is hand-edited. CI misses this: the
  policy generator test only exercises the explicit-fields path
  (`cafe_car:policy client name email`, which works) and never renders a
  resource-generated policy.

Verified working (no-edit) path, for reference: `cafe_car:install` →
`cafe_car:sessions` → `rails g model User email:string` → `rails g model Product
name:string price:decimal` → `cafe_car:controller Product` → `cafe_car:policy
Product name price` (fields passed explicitly to dodge B/C) → `db:migrate` →
`server` → `/products` renders (HTTP 200, real admin index). 8 commands, not a
60-second try.

Put a minimal, copy-pasteable quickstart block near the very top of `README.md` (above the
deeper "Manual Setup" material) that gets a skeptic from zero to a working admin without
reading further. Attacks the activation-friction / trust barrier (CafeCar's core growth
constraint per `AGENTS.md`).

**Acceptance criteria — accuracy is the whole point:**

- The block MUST be verified to actually work end-to-end. Run the commands against the repo's
  dummy app (or a scratch Rails app) before writing them down. A quickstart that fails on
  step 2 is worse than no quickstart — it burns trust.
- Use the real command surface. Confirm the exact generator names/args (e.g. whatever the
  current `rails g cafe_car:*` generators are) rather than guessing from the IDEAS note.
- Keep it tight: install → generate → run → visit the admin URL. No prose padding. If the
  happy path genuinely needs N commands, show N — don't fake a shorter path.
- Don't duplicate the existing detailed setup docs; this is the fast on-ramp that links down
  to them for the full story.
- Any customer-visible prose passes the voice gate (anti-slop) — but this block is mostly
  code, so keep prose to a sentence or two.

Constraints: README-only change (+ any doc it links). Run `bundle exec rake` (rubocop + test +
brakeman) green before pushing. Update this task to `done` and regenerate `TASKS.md`
(`bundle exec rake tasks:index`). IDEAS.md row for this idea is being flipped to `running` by
the conductor; set it to `kept` (with the commit SHA) if it ships clean.

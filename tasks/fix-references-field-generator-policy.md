---
id: fix-references-field-generator-policy
title: cafe_car:resource generates an unsavable policy for belongs_to/:references fields
priority: P1
status: open
domain: Eng
created: 2026-07-02
---

**Source:** completeness audit 2026-07-02 (graybeard), blocker #4. Confirmed by running the
generator end-to-end and reading the emitted file.

**Bug:** `rails g cafe_car:resource Order invoice:references price:decimal` produces a policy with
`permitted_attributes: [:invoice, :price]` — but the column/strong-param Rails needs is
`:invoice_id`. The association silently can't be saved. `:references`/`belongs_to` is the single
most common real-world field type, and this hits adopters immediately after the v0.2.1 onboarding-500
fix — back-to-back onboarding failures read very differently than one clean fix.

**Root cause:** `lib/generators/cafe_car/resource/resource_generator.rb:28`
`field_names = attributes.map { _1.to_s.split(":").first }` strips the type and forwards bare
`"invoice"`. `lib/generators/cafe_car/policy/policy_generator.rb:50` + template render it verbatim.
The codebase already knows the right pattern — `lib/generators/cafe_car/notes/notes_generator.rb`
correctly hardcodes `notable_id notable_type` — so this is an oversight, not a design choice.

**Fix:** Translate `:references`/`belongs_to` field names to their `_id` form before forwarding to
`cafe_car:policy` (mirror the pattern already correct in `notes_generator.rb`). Handle polymorphic
`:references{polymorphic}` (`_id` + `_type`) too.

**Acceptance:**
- `resource_generator_test.rb` / `policy_generator_test.rb` exercise a `:references` field (only
  scalar types are tested today) and assert the emitted policy permits `:invoice_id`.
- Ideally an integration guard: generate a resource with a belongs_to, submit its real form, assert
  the association persists.
- `bundle exec rake` green. `CHANGELOG.md` `[Unreleased]` entry.

Shares a root cause with [[fix-nested-hasmany-forms-not-saving]] — do them together with one
integration-level "generate → submit every field type → assert persistence" guard.

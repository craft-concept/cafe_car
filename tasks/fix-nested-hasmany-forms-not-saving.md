---
id: fix-nested-hasmany-forms-not-saving
title: Nested has_many forms silently fail to save (flagship feature broken)
priority: P1
status: open
domain: Eng
created: 2026-07-02
---

**Source:** completeness audit 2026-07-02 (graybeard), blocker #1. Empirically reproduced
against the dummy app — not a code-reading guess.

**Bug:** Submitting a form with nested `accepts_nested_attributes_for` records (e.g. Invoice +
`line_items`) does NOT persist the nested records. No error, no crash — HTTP 200, data silently
dropped. Silent data loss is worse than a 500: discovered in production, not dev.

**Root cause:** `test/dummy/app/policies/invoice_policy.rb:10-11` permits `line_items:`, but Rails'
`fields_for` always names the param `line_items_attributes`. Strong-params `#permit` matches keys
exactly → the nested payload never matches → `assign_attributes` (`lib/cafe_car/controller.rb:~146`)
strips it. Compounding: `line_item_policy.rb`'s `permitted_attributes` omits `:id` and `:_destroy`,
so `allow_destroy: true` (declared on `Invoice`) can't update/delete existing rows either — only
create phantom rows that also don't save.

**Fix:** Make the generated/permitted policy layer match what Rails' form helpers actually send —
`*_attributes` suffix for nested associations, and include `:id` + `:_destroy` when the parent
declares `allow_destroy`. Fix both the dummy policies AND the **policy generator template** so newly
generated policies don't reproduce this. Consider generating nested-attribute permits automatically
when the model has `accepts_nested_attributes_for`.

**Acceptance:**
- A POST/PATCH round-trip test that submits a nested `has_many` form and asserts the child records
  exist afterward (create), update an existing child, and destroy one via `_destroy`. This is the
  test that should have existed — the current `test/controllers/nested_fields_test.rb` only asserts
  GET-rendered markup.
- `bundle exec rake` green. Released-gem behavior fix → `CHANGELOG.md` `[Unreleased]` entry.

Shares a root cause with [[fix-references-field-generator-policy]] (generated permit layer not
matching Rails runtime param names) — do them together.

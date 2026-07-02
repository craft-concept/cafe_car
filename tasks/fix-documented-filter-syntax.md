---
id: fix-documented-filter-syntax
title: Documented advanced-filter syntax (price.min=10, .gt, .lt) is a silent no-op
priority: P1
status: open
domain: Eng
created: 2026-07-02
---

**Source:** completeness audit 2026-07-02 (graybeard), blocker #2. Filtering/search is headline
positioning — it's in the gemspec summary/description (the RubyGems.org listing), not just the README.

**Bug:** The README documents filter syntax like `price.min=10`, `price.gt=5`, `.eq`/`.lt`/`.max`.
None of it works — bare filter keys are silently dropped (unfiltered result set returned, no error).
A developer copy-pastes the documented example, gets a silent no-op, and concludes the gem is broken.

**Root cause:**
- `lib/cafe_car/param_parser.rb#params` splits each key on `.` — a bare key like `"price"` never
  lands under the `""` wrapper key that `filtered` reads; only a literal leading-dot key (`.price`)
  does (`".price".split(".") => ["", "price"]`).
- `lib/cafe_car/controller/filtering.rb#filtered` only reads `parsed_params[""]`.
- `lib/cafe_car/query_builder.rb#param!` recognizes comparison operators only as a literal
  `<`/`<=`/`>`/`>=` character suffix on the key, NOT as the documented `.min`/`.max`/`.gt`/`.lt`/`.eq`
  words. No code path anywhere handles the word-form operators.
- The gem's own `test/controllers/keyword_search_test.rb:32` uses the undocumented `.name` dot-prefix
  syntax — the team's tests never validate the documented syntax because it doesn't work.

**Fix:** Pick ONE canonical syntax and make code + docs + tests agree. Recommend fixing the parser to
accept bare dot-less keys with word-form operators (`price.min`, `price.gt`) — that's what the README
already promises and what any user types first — then remove or clearly gate the undocumented
dot-prefix form.

**Acceptance:**
- Tests exercise range + comparison filters using the **documented** syntax (none exist today).
- README filter examples verified to actually work end-to-end.
- `bundle exec rake` green. `CHANGELOG.md` `[Unreleased]` entry.

---
id: fix-halfbaked-features
title: Fix the half-baked features (auth/sessions first)
priority: P1
status: done
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Stabilize the features the audit flags as broken/incomplete. Stability is half of the
"ship + trust" mission — a feature that 500s is worse than a missing one.

Authoritative list is in `V1_SCOPE.md`. Most items are now shipped — only item 5 remains:

1. ✅ Auth/sessions latent 500 → done via [[sessions-optional-and-finish]] (graceful 403 +
   feature finished).
2. ✅ `sessions` generator USAGE → fixed in the sessions work.
3. ✅ README false advertising → fixed via [[readme-badges-accuracy]].
4. ✅ Missing generator tests → done via [[generator-test-coverage]] (3 → 21 generator tests).
5. ✅ Coverage for advertised-but-unverified paths → done. Verified 2026-06-26:
   `test/controllers/json_responses_test.rb` (2 tests), `turbo_stream_test.rb` (3),
   `sort_and_paginate_test.rb` (3), and `test/presenters/cafe_car/record_presenter_test.rb`
   (4, direct `present(obj)` render) all exist, are active, and pass. The whole V1_SCOPE
   "must-fix" list is now closed.

- Every fix lands with a regression test. `rake` green before push.

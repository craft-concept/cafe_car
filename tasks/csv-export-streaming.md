---
id: csv-export-streaming
title: Stream CSV export instead of loading the whole table into memory
priority: P3
status: open
domain: Eng
created: 2026-06-27
---

Follow-up from the 2026-06-27 security/correctness review of [[csv-export]]. The `:csv`
renderer (`lib/cafe_car/engine.rb`) does `Array(collection).each { … }`, materializing the
entire policy-scoped, un-paginated result set in memory before sending. On a large table this is
a memory/latency DoS vector (an admin exporting a 1M-row resource).

- Switch to row-streaming: `find_each` + an enumerator/`response.stream`, or cap exported rows
  with a clear truncation signal (and `log`/document the cap).
- Keep the policy-scoped column basis and the formula-injection guard already in place.
- Low priority — fine for the small admin tables CafeCar targets today; revisit before touting
  CSV for large datasets.

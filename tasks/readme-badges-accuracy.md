---
id: readme-badges-accuracy
title: README badges + fix inaccuracies
priority: P1
status: open
domain: Marketing
created: 2026-06-26
---

The README is the storefront. Add credibility badges and remove statements that don't
match reality (false promises erode trust faster than missing features).

- Badges: CI status, gem version (RubyGems), license, maybe downloads.
- Accuracy pass against [[feature-audit-v1-scope]]: e.g. the install section claims the
  generator adds `bcrypt, paper_trail, factory_bot_rails` — verify against the actual
  generator + gemspec (gemspec does not declare paper_trail/factory_bot). Fix mismatches.
- Confirm Rails/Ruby version floors in "Prerequisites" match the gemspec/CI matrix.

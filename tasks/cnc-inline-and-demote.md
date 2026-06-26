---
id: cnc-inline-and-demote
title: Inline cnc's two core-ext methods, demote cnc to dev dependency
priority: P1
status: open
domain: Eng
created: 2026-06-26
blocked_on: user
---

Execution of the [[cnc-keep-or-drop]] recommendation (see QUESTIONS.md). Blocked on the
owner ratifying the dependency-strategy decision they asked us to recommend on.

Plan once approved:
- Inline `Hash#extract_if!` and `Module#define_class` (~10 lines each, currently from
  `cnc/core_ext`) into `lib/cafe_car/core_ext/` alongside the existing `array.rb` extras,
  matching its style.
- Drop `require "cnc/core_ext"` from `lib/cafe_car/core_ext.rb`.
- Move `cnc` from `add_dependency` to `add_development_dependency` in the gemspec (keeps
  `.rubocop.yml`'s `inherit_gem: cnc` for contributors; removes rubocop/thor/listen from
  production installs).
- Verify callers: `component.rb:22,64`, `helpers.rb:28`, `ui.rb:8`. `rake` green.
- Owner decision points (QUESTIONS.md): inline-and-demote (default) vs. keep-runtime vs.
  also-inline-the-rubocop-config-and-drop-entirely.

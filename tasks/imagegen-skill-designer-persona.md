---
id: imagegen-skill-designer-persona
title: Note the fleet /imagegen skill in the designer persona
priority: P2
status: done
domain: Brand
created: 2026-06-28
blocked_on: none
---

Mirrors holdco board task `new-fleet-imagegen-skill-use-it-for-visual-assets-run-imageg`.

A new fleet `/imagegen` skill is on PATH (`imagegen "<prompt>" [--quality low|medium|high]
[--size WxH]`, also `/imagegen`); it generates icons, mockups, hero/marketing images, and
OG/social cards, printing the saved PNG path. Generations run as **independent parallel codex
processes** — fire several at once with `&`, don't wait for one to finish.

**Done:** wired the tool into `.claude/agents/designer.md` item 5 ("Visual assets") as the default
generator, with the parallel-fire guidance, so every future designer spawn reaches for it on visual
work. Verified `imagegen` resolves on PATH (`/home/yaks/.local/bin/imagegen`).

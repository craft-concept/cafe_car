---
id: visual-assets-og-card
title: Generate CafeCar visual assets (OG/social card first) via the imagegen skill
priority: P2
status: done
domain: Design
created: 2026-06-27
---

## DONE (pass 27) — OG card delivered

Designer generated 3 parallel `imagegen` variants and shipped the strongest: a clean dev-tool card
(wordmark "CafeCar" + Ruby-red diamond, BRAND.md-verbatim tagline "A complete Rails admin from one
line of controller code", and a realistic auto-generated admin table — sortable headers with a red
active-sort arrow, Active/Invited/Inactive status badges, avatars, pagination). It *shows* the CRUD
output rather than claiming it (on-voice "show, don't claim"). Reviewed the rendered PNG — legible,
on-brand, crop-safe for GitHub's 2:1 trim.

- **Asset:** `docs/images/og-card.png` (1731×909, ~1.9:1 PNG), committed `51ef230`.
- **Wiring (owner step, tracked in `owner-one-time-dashboard-wiring`):** GitHub social preview is a manual Settings → General →
  Social preview upload (NOT settable via the REST API). Launch-post `og:image` should point at
  `https://raw.githubusercontent.com/craft-concept/cafe_car/main/docs/images/og-card.png`.

Mirrors holdco board task `new-fleet-imagegen-skill-use-it-for-visual-assets-run-i` (filed
2026-06-27 23:00): a fleet `imagegen` skill is now on PATH
(`imagegen "<prompt>" [--quality low|medium|high] [--size WxH]`, bills the Codex subscription,
runs headless and in parallel — fire several with `&`). Use it for icons, mockups, hero/marketing
images, OG/social cards.

CafeCar's clearest visual-asset gap is an **OG/social card** — it makes shared repo and launch-post
links render a professional preview, directly supporting the prepped (owner-gated)
[[discoverability-launch]]. Now that [[brand-voice-guide-and-sweep]] shipped BRAND.md, the card can
be brand-grounded.

## Scope (this task — OG card)
- Generate a CafeCar OG/social card with `imagegen`, grounded in BRAND.md (unhyped, technical,
  Rails-native; "show, don't claim"). Wordmark "CafeCar" + the on-voice headline "A complete Rails
  admin from one line of controller code." Clean developer-tool aesthetic, Ruby/Rails red accent,
  a subtle admin-table or café-car motif — not a flashy marketing banner.
- Landscape, OG-suitable. Commit the chosen PNG under `docs/images/`.
- Deployment note: setting it as the GitHub repo social preview is a Settings/`gh api` action
  (owner or scoped) — record that as the wiring step; the committed asset is what unblocks it.

## Follow-up (broader visual set — sequence with launch / designer refresh)
Logo/icon (README + social avatar) and a favicon for the demo/docs site. Hold until the OG card
lands and, ideally, the designer-persona refresh (per [[brand-voice-guide-and-sweep]]) so the
whole visual identity is brand-consistent.

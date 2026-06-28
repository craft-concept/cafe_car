---
id: visual-assets-logo-favicon
title: CafeCar brand mark (logo/icon) + branded demo favicon
priority: P2
status: done
domain: Design
created: 2026-06-27
---

Follow-up visual set flagged in the imagegen-adoption note (OG card was the first asset,
`51ef230`): a logo/icon + favicon were "queued with the launch + designer-persona refresh."
Visual assets are NOT copy, so they're not gated on the voice-gate persona refresh (that gates
customer-visible *copy* via `/copy`, not imagery) — the OG card already proved the current
`designer` persona drives `imagegen` end to end. Shipping a brand mark now strengthens repo
identity for the launch and removes the default-Rails-favicon tell on the live demo.

## Scope

1. **Brand mark** — a CafeCar logo/icon, grounded in `BRAND.md` (Rails-native, terse, unhyped;
   visually consistent with `docs/images/og-card.png`). Generate variants in parallel with
   `imagegen`, pick the crop-safe / favicon-legible one. Deliver a clean square mark
   (`docs/images/logo.png`, large enough to downscale) suitable for README, repo, and favicon.
2. **Demo favicon** — replace the default Rails favicon on the demo (the `test/dummy` app, which
   IS the live demo). Wire the Rails 8 way: `app/assets/images/icon.png` + `icon.svg` if present,
   or `public/favicon.ico`, referenced from the dummy layout. Verify it renders.
3. **README** — optionally add the mark tastefully near the top (small wordmark/icon, not a
   giant banner — there's already a hero screenshot below the fold). Designer's judgment.

## Constraints

- Disjoint files: `docs/images/*`, `test/dummy/app/assets/images/*` /
  `test/dummy/public/favicon.*`, the dummy layout, and `README.md` top matter only.
- Run `rake` (rubocop + test + brakeman) green before committing; commit + push.
- Do NOT route any new customer-visible *copy* through this — copy still waits on the voice-gate
  refresh ([[brand-voice-guide-and-sweep]] part 2).

## Notes (done 2026-06-27)

- Brand mark: `docs/images/logo.png` — white faceted gem on a red (#E63329) rounded square,
  the same icon motif as `docs/images/og-card.png`. Picked from 4 parallel `imagegen` variants
  (filled-white-gem-on-red, busy round-cut-on-white, cream-tile outline gem, container-less gem)
  for being the most favicon-legible at 16px and crop-safe (mark is the tile itself). 512x512.
- Demo favicon (`test/dummy/public/`): `favicon.ico` (16/32/48), `icon.png` (512),
  `apple-touch-icon.png` + `apple-touch-icon-precomposed.png` (180), corners transparent.
  Wired via public/ auto-discovery — the dummy renders through the engine's shared
  `app/views/application/_head.html.haml`, which is out of scope to edit, so no layout/head
  change was needed. Verified: booted dummy served `/favicon.ico`, `/icon.png`,
  `/apple-touch-icon.png` all HTTP 200 with correct MIME types.
- README: gem icon inlined into the H1 (decorative `alt=""`); no new copy.

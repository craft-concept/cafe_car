---
id: owner-one-time-dashboard-wiring-railway-config-as-code-githu
title: Owner one-time dashboard wiring (Railway config-as-code, GitHub App auto-deploy, OG social card upload)
priority: P2
status: open
domain: Ops
created: '2026-06-30'
blocked_on: user
---

Three one-time owner/dashboard actions, all **non-blocking** (workarounds hold), grouped so they
don't get lost. None needs code; each is a console/settings click only the owner can do.

_Migrated from the retired QUESTIONS.md (entries dated 2026-06-27/28). Detail preserved below._

1. **Activate `railway.toml` config-as-code on the demo service.** The repo has a `railway.toml`
   pinning the demo to the Dockerfile builder (`builder = "DOCKERFILE"` + `startCommand =
   "bin/railway-demo"`), but Railway shows `configFile: null` — the toml is inert (config-as-code
   is disabled for this service and can't be enabled via API). Homelab pinned the equivalent
   settings at the service level, so the demo is stable **now**; the toml won't be the source of
   truth until someone points the service's config file at `railway.toml` (Service → Settings →
   Config-as-code). Non-blocking — the service-level pin already holds.

2. **Install the Railway GitHub App for auto-deploy.** The live demo (`cafe-car-demo`) does **not**
   auto-deploy on push to `main`: root cause `NO_INSTALLATION` — the Railway GitHub App is not
   installed on `craft-concept/cafe_car`, so there's no GitHub→Railway webhook. Owner action:
   install https://github.com/apps/railway on the repo, then enable auto-deploy on the service.
   Until then, demo deploys are triggered manually (Railway MCP / homelab) after demo-affecting
   pushes.

3. **Upload the OG/social card to GitHub.** A brand-grounded OG card lives at
   `docs/images/og-card.png` (committed `51ef230`) so shared links render a professional preview.
   GitHub's social preview can't be set via API — upload it manually at Settings → General →
   Social preview on `craft-concept/cafe_car`. (Launch-post `og:image` can reference the raw URL:
   `https://raw.githubusercontent.com/craft-concept/cafe_car/main/docs/images/og-card.png`.)
   Tracked as the wiring step of `visual-assets-og-card`.

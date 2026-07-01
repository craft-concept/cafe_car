---
id: adoption-polish-from-bullhorn-audit
title: Unblocked adoption/conversion polish (from pass-63 bullhorn GTM audit)
priority: P2
status: done
domain: Marketing
created: 2026-07-01
completed: 2026-07-01
blocked_on: none
---

**DONE (Pass 64).** All operator-shippable findings landed on `main`, CI green:
- Copy (`1a34afa`, designer/voice-gated): benefit-led README hero, tagline subtitle,
  sharpened "Perfect for" audience line, star CTA, "try it in 60s" macro-path quickstart
  above the fold, and refreshed gemspec summary/description (keyword search, filtering,
  CSV export, Pundit, Hotwire — ships to RubyGems next release).
- Docs-site SEO (`28f439b`, coder): wired OG/Twitter meta + `og:image` (og-card.png) +
  sitemap via the theme's built-in `{% seo %}` (jekyll-seo-tag) rather than a hand-rolled
  `head-custom.html` — avoids duplicate/conflicting tags; verified by a scratch Jekyll build.
- Skipped by design: docs analytics counter (optional, owner may prefer none).

**Residual — owner-gated only:** GitHub *repo* social-preview upload lives in
`owner-one-time-dashboard-wiring-railway-config-as-code-githu`. Nothing else outstanding here.

Pass 63 ran a `bullhorn` GTM audit for **unblocked** adoption levers (things shippable without the
owner's launch accounts). The P0 finding — the published-gem onboarding crash — is being fixed by
the **v0.2.1 release** (separate). This task holds the remaining operator-shippable findings, ranked
by leverage÷effort. Customer-visible copy items must pass the voice gate (`/copy` / `designer` per
`AGENTS.md`); technical items go to `coder`. Work these down over subsequent passes — they're the
unblocked adoption backlog.

## Copy (route through the voice gate / `designer`)

- **[High/S] README hero paragraph is mechanism-first, undersells.** README.md ~L28–32 leads with
  "extends the MVC view layer to provide automatic CRUD UI generation…". Rewrite benefit-led,
  reusing the sharper framing already proven in `marketing/launch-post.md` (the "Rails should render
  something by default / the view layer sits there with its hands in its pockets" gap). Suggested
  direction: model already knows its columns → Rails still makes you hand-write a controller + 7
  actions + views → `cafe_car` closes that gap (index/show/new/edit from the model, with Pundit +
  filtering + Hotwire) → every default is a starting point, not a cage.
- **[Med/S] Gemspec summary/description stale + missing search real estate.** `cafe_car.gemspec`
  L9–16 omits **keyword search** and **CSV export** (shipped in 0.2.0) and "Pundit"/"Hotwire" —
  terms devs search on RubyGems/Google. (No dedicated `keywords` field exists; summary+description
  IS the entire SEO lever.) Refresh to name CRUD, keyword search, filtering, CSV export, Pundit
  auth, "no DSL", "every default overridable". Ships to RubyGems on the next release.
- **[Low-Med/S] Brand tagline absent from README.** The repo description
  ("🚋 Recline in the cafe car while your Rails views build themselves.") is memorable but isn't in
  README.md — add as an italic subtitle under the H1.
- **[Low/S] "Perfect for" line generic.** README.md ~L34 "Admin panels, internal tools, and rapid
  prototyping" → sharpen to name the audience (Rails devs who need a working admin this week, not a
  second framework to configure).
- **[Low/S] No star CTA.** Add one line near Contributing ("If CafeCar saves you an afternoon, a
  star helps other Rails devs find it.").

## Structure (mostly `coder`; the quickstart block wording is copy)

- **[High/S-M] Quickstart CTA buried below the fold.** README pushes Installation to ~L109 (past a
  26-line TOC + comparison table + features). Add a tight 3-block "try it in 60s" fenced snippet
  right after the hero caption. **Use the macro/manual path** (`cafe_car` on a controller) — do NOT
  reintroduce the resource-generator one-liner as the hero snippet (it was the 0.2.0 crash; safe
  again on 0.2.1, but the macro path is the cleanest first touch). Verify against the shipped gem.

## Docs-site SEO (`coder` — technical, fully unblocked)

- **[Med-High/S] docs/ ships zero SEO/social metadata; the OG asset is wired to nothing.**
  `docs/_config.yml` has no plugins; `docs/images/og-card.png` (committed) is referenced only by a
  raw URL in the launch post. The cayman theme supports a `_includes/head-custom.html` hook. Add
  `docs/_includes/head-custom.html` with `og:title`/`og:description`/`og:image` (raw og-card.png
  URL), `twitter:card=summary_large_image`, and a canonical link; add `plugins: [jekyll-sitemap]`
  to `docs/_config.yml` (GitHub-Pages-supported, no Gemfile change) for `sitemap.xml`.
  NOTE: the *GitHub repo* social-preview upload is separately owner-gated (see
  `owner-one-time-dashboard-wiring-railway-config-as-code-githu`) — only the docs-site meta is in
  scope here.
- **[Low-Med/S] No docs analytics.** Optionally add a privacy-friendly counter (Plausible/GoatCounter)
  script to the same `head-custom.html`. Meanwhile GitHub repo Insights → Traffic is free and should
  be checked periodically. (Owner may prefer no third-party analytics — light-touch / optional.)

## Explicitly out of scope / already handled
- The launch publish (marketing/ kit) — owner-gated, tracked in `discoverability-launch`.
- The comparison table (README L63–83) — audit flagged it as a genuine strength; **leave as-is**,
  don't "improve" it into marketing fluff.
- GitHub repo social-preview upload — owner-gated (`owner-one-time-dashboard-wiring-…`).

---
id: docs-site-live-demo
title: Docs site + live clickable demo
priority: P2
status: done
domain: Marketing
created: 2026-06-26
---

Roadmap item #5. The single highest-converting trust artifact: let skeptics evaluate
CafeCar without installing it.

- Live demo: the `test/dummy` app already exists and CI even screenshots `/articles` —
  deploy a seeded instance (Railway is wired into this session) so people can click
  around real auto-generated CRUD.
- Docs site: GitHub Pages from the README to start; expand later.
- Gate on [[feature-audit-v1-scope]] so the demo only exposes v1-quality features.

## Outcome (2026-06-26)

**Live demo:** https://cafe-car-demo-production.up.railway.app — one click from the
root page ("Enter the demo →") lands on the auto-generated `/admin` CRUD for clients,
invoices, articles, users, and notes, all seeded with FactoryBot data. Show pages,
filtering, sorting, and pagination all render.

Deployed the existing `test/dummy` app to Railway (project "CafeCar Demo",
service `cafe-car-demo`) from a root `Dockerfile` that builds the whole repo (the
dummy loads the gem via `gemspec`), precompiles assets, and reseeds an ephemeral
SQLite database on every boot via `bin/railway-demo` — so visitor edits self-clean
on each restart. No auth changes were needed: the dummy's Pundit policies already
grant access, so the admin is reachable in one click. `production.rb` gained
`assume_ssl`, static-file serving, and Railway host-authorization. A "data resets
periodically" banner sits on the home page.

The GitHub Pages docs site (`docs/`) and README both link the demo prominently.
Follow-up: GitHub Pages itself still needs to be enabled for the repo (Settings →
Pages → deploy from `docs/`).

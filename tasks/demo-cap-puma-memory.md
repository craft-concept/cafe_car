---
id: demo-cap-puma-memory
title: Cap demo Puma memory — force single-process (was 48 workers / 3GB+ RSS)
priority: P1
status: done
domain: Ops
created: 2026-06-28
blocked_on: none
resolved: 2026-06-28 (commit 372af21; awaiting homelab redeploy + boot-log verify)
---

Mirrors holdco board task `cafe-car-demo-durably-cap-memory-was-3gb-and-climbing` (P1, filed
2026-06-28 07:05 by homelab). Demo was burning ~$30/mo against the Railway spend cap.

## Root cause (homelab diagnosis, confirmed in-repo)

`test/dummy/config/puma.rb` boots Puma in **cluster mode** in production with one worker per host
CPU core: `worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })`.
The container sees the host's 16–48 cores → 16–48 Rails workers → 3GB+ RSS. Homelab set the Railway
service var `WEB_CONCURRENCY=1` and redeployed 3× but it did **not** reach Puma at runtime (still
booted 48 workers).

## Fix (two-pronged, builder-agnostic)

1. **`test/dummy/config/puma.rb`** — change the production fallback default from
   `Concurrent.physical_processor_count` to `1`. This is the root-cause fix: the demo never wants
   more than one worker on shared/capped infra, and it survives a Dockerfile→RAILPACK builder
   switch (homelab warned the builder flips by commit). `concurrent-ruby` require can stay or go;
   with default 1 it's only needed when WEB_CONCURRENCY is explicitly set high.
2. **`Dockerfile`** — add `WEB_CONCURRENCY=1` to the `ENV` block so it's baked into the image and
   present at runtime regardless of Railway var propagation (belt-and-suspenders under the Docker
   builder).

`MALLOC_ARENA_MAX=2` is already set on the service and stays.

## Verify

- `rake` green (rubocop + test + brakeman).
- After merge, homelab redeploys; boot logs must show single-process mode (NO "cluster mode", NO
  "Worker N booted"). Demo stays HTTP 200 on `cafe-car-demo-production.up.railway.app`.

Notify homelab once the in-repo fix lands on main so they redeploy + confirm.

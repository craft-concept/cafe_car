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

## Follow-up (2026-06-28): root cause was the BUILDER, not just worker count

Homelab redeployed and the memory cost is solved (48→1), but the boot log still literally read
"Puma starting in cluster mode" + "WARNING: cluster mode with 1 worker" — which contradicts
`test/dummy/config/puma.rb` (only calls `workers` when `WEB_CONCURRENCY > 1`). Removing the leftover
`WEB_CONCURRENCY=1` service var didn't change it. Root cause: **the live deploy was being built by
Railpack, not our Dockerfile.** The Rails app is nested in `test/dummy`, which Railpack can't intuit
— it auto-generated a start command + loaded a Puma config that forces cluster mode, bypassing our
Dockerfile and puma.rb entirely. So the "builder-agnostic via puma.rb" assumption was wrong; the
real fix is to remove builder ambiguity.

**Fix:** added `railway.toml` pinning `[build] builder = "DOCKERFILE"` + `[deploy] startCommand =
"bin/railway-demo"`, so the Dockerfile (which correctly cds into test/dummy, reseeds, and boots
single-process Puma) is always authoritative. This also resolves the original task's builder-flip
concern. Homelab to redeploy + confirm build uses the Dockerfile and boot shows single mode.

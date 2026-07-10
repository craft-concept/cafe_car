---
name: sharing
description: >
  Publish or unpublish a file on the public web (public.yak.sh), or explain what
  ~/shared is — use when asked to make a shared file public, share a file, put
  something on public.yak.sh, get a public/tailnet link for an artifact, or take a
  published file down.
scope: fleet
volatility: stable
---

# Sharing files — `~/shared`, tailnet-private by default, public on request

`~/shared` (`/home/yaks/shared`) is the fleet's file-share tree. It is served **two** ways:

- **Private (default):** the whole tree is served read-only over the owner's **Tailscale
  tailnet** at `https://shared.yak.sh/<path>` — the owner's devices only, not the public
  internet. (The old `https://claude.ibis-micro.ts.net/<path>` still works as a legacy alias.)
- **Public (opt-in, per file):** a file is on the open internet at `https://public.yak.sh/<path>`
  **iff its sticky bit is set**. Nothing is public until you mark it.

`<path>` in both URLs is the file's path **relative to `~/shared`** — strip the
`/home/yaks/shared/` prefix. Example: `~/shared/<venture>/demo.png` →
`https://shared.yak.sh/<venture>/demo.png` (private) or
`https://public.yak.sh/<venture>/demo.png` (public, once published).

> **SAFETY — public means anyone with the link.** `public.yak.sh` is the open internet.
> **Never publish secrets, credentials, `.env`, PII, or customer data.** There's no directory
> listing, but any link you share is fully world-readable. Default to the private tailnet link;
> reach for public only when an outside party must open it. When in doubt, don't publish.

## Publish / unpublish

```bash
chmod +t ~/shared/<venture>/<file>    # publish → https://public.yak.sh/<venture>/<file>
chmod -t ~/shared/<venture>/<file>    # unpublish → 404
```

The **sticky bit** is the switch (not `chmod +x`, which would collide with genuinely-executable
files and publish their source). On a regular file the sticky bit is kernel-ignored and git
ignores it, so publishing dirties nothing.

## How-to notes

- **The file must live under `~/shared` to be linkable at all.** A `/tmp` scratchpad or a path
  inside a repo is not served — write or copy the artifact into `~/shared/<venture>/` first, then
  link it.
- **Markdown auto-renders** to styled HTML on `public.yak.sh`; append **`?raw=1`** for the source.
- **Publishing a repo file:** symlink it into `~/shared` and set the sticky bit on the regular
  file — the repo stays clean (git tracks only owner-execute, not the sticky bit).
- **Verify** after publishing: `curl -sS https://public.yak.sh/<venture>/<file>` should return the
  content; after `chmod -t`, the same URL should 404.

Deep architecture (server, tunnel, provisioning) lives in holdco's `docs/PUBLIC-SHARING.md` — that
doc is holdco-only, so the how-to above is self-contained for a venture.

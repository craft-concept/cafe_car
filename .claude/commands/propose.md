---
description: File a 💡 proposal to the owner on the Task Graph. Takes a vetted
  one-paragraph pitch — thesis · cost · expected value. Files as a P2 task under this
  venture's project so it reaches the owner.
argument-hint: "<thesis · cost · expected value pitch>"
disable-model-invocation: true
allowed-tools: Bash
---

## File proposal: $ARGUMENTS

A **proposal** is a consequential idea that needs the owner's call (irreversible, money out, brand
pivot, legal, or an owner-only resource — see `AGENTS.md` → "Ideation"). It should already be
vetted by a quick panel mini-review and phrased as **thesis · cost · expected value**.

File the proposal from $ARGUMENTS on the Task Graph. Use the thesis (first sentence) as the title,
and make the body's **first line** exactly `kind: proposal` — that marker is what routes it into the
owner's `bin/holdco asks` **💡 Proposals** digest (v2 has no proposal column yet; this body-line
convention is how the digest detects one). Put the cost · expected value on the lines after it.

```bash
task new P2 .project=cafe_car .title="<THESIS>" .body="kind: proposal
<cost · expected value>"
```

Confirm the id it prints, then add a `proposed` row to `IDEAS.md`.
